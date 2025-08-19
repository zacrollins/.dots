# Nx Completion Plugin for Zsh
#
# Features:
# - Dynamic command parsing from 'nx --help' output
# - Automatic caching of parsed commands and options
# - Fallback to Nx cached project graph (.nx/workspace-data/project-graph.json)
# - Dynamic option parsing for individual commands
# - Support for workspace projects, targets, and generators
#
# Performance optimizations:
# - Uses cached project graph when available
# - Caches dynamically parsed commands and options
# - Implements zsh completion caching policy

# @todo: Document.
_nx_command() {
  echo "${words[2]}"
}

# @todo: Document.
_nx_arguments() {
  # Don't enable option stacking for generate command as generators are positional arguments, not stackable options
  local command_name="${words[1]}"
  if [[ "$command_name" == "generate" || "$command_name" == "g" ]]; then
    return
  fi

  if zstyle -t ":completion:${curcontext}:" option-stacking; then
    print -- -s
  fi
}

# Describe the cache policy.
_nx_caching_policy() {
  oldp=( "$1"(Nmh+1) ) # 1 hour
  (( $#oldp ))
}

# Global configuration for maximum number of completion results
typeset -g NX_MAX_RESULTS=30

# Set up zsh completion styles for nx to ensure menu completion
zstyle ':completion:*:*:nx:*' menu yes select
zstyle ':completion:*:*:nx:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:*:nx:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*:*:nx:*' group-name ''
zstyle ':completion:*:*:nx:*' completer _complete
zstyle ':completion:*:*:nx:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:nx:*' accept-exact-dirs true
zstyle ':completion:*:*:nx:*' list-separator --

# Check if at least one of w_defs are present in working dir.
_check_workspace_def() {
  integer ret=1
  local files=(
    "$PWD/angular.json"
    "$PWD/workspace.json"
    "$PWD/nx.json"
  )

  # return 1 if none of the files are present.
  for f in $files; do
    if [[ -f $f ]]; then
      ret=0
      break
    fi
  done

  # To get all workspace projects and targets nx graph needs to be called to store the
  # data in a file.
  if [[ $ret -eq 0 ]]; then
    local cwd_id=$(echo $PWD | (command -v md5sum &> /dev/null && md5sum || md5 -r) | awk '{print $1}')
    tmp_cached_def="/tmp/nx-completion-$cwd_id.json"

    # Check if Nx cached project graph exists first
    local nx_cached_graph="$PWD/.nx/workspace-data/project-graph.json"
    if [[ -f "$nx_cached_graph" ]]; then
      tmp_cached_def="$nx_cached_graph"
    else
      # Generate new graph file if cached one doesn't exist
      nx graph --file="$tmp_cached_def" > /dev/null 2>&1
    fi
  fi

  return ret
}

# Read workspace definition from generated tmp file.
# Assumes _check_workspace_def get called before.
_workspace_def() {
  integer ret=1

  # First check if tmp_cached_def is set and file exists
  if [[ -n "$tmp_cached_def" && -f "$tmp_cached_def" ]]; then
    echo "$tmp_cached_def" && ret=0
    return ret
  fi

  # Fallback: re-run workspace detection if tmp_cached_def is not set
  if _check_workspace_def; then
    if [[ -n "$tmp_cached_def" && -f "$tmp_cached_def" ]]; then
      echo "$tmp_cached_def" && ret=0
    fi
  fi

  return ret
}

# Helper function to get the correct nodes path based on JSON structure
_get_nodes_path() {
  local def="$1"
  if [[ -f "$def" ]]; then
    # Check if the JSON has .graph.nodes or directly .nodes
    if jq -e '.graph.nodes' "$def" >/dev/null 2>&1; then
      echo ".graph.nodes"
    elif jq -e '.nodes' "$def" >/dev/null 2>&1; then
      echo ".nodes"
    else
      # Fallback to .nodes for backwards compatibility
      echo ".nodes"
    fi
  else
    echo ".nodes"
  fi
}

# Unified function to get workspace items (projects or targets)
_get_workspace_items() {
  local item_type="$1" # "projects" or "targets" or "targets_full"
  integer ret=1
  local cache_key="nx_workspace_${item_type}"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check if we have cached items and they're still valid
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  local def=$(_workspace_def)
  local nodes_path=$(_get_nodes_path "$def")
  local -a items=()

  case "$item_type" in
    projects)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(<$def | jq -r '.graph.nodes[] | .name'))
      else
        items=($(<$def | jq -r '.nodes[] | .name'))
      fi
      ;;
    targets)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(jq -r '[.graph.nodes[] | .data.targets | keys[]] | unique[]' "$def"))
      else
        items=($(jq -r '[.nodes[] | .data.targets | keys[]] | unique[]' "$def"))
      fi
      # Limit results for better performance
      if [[ ${#items} -gt $NX_MAX_RESULTS ]]; then
        items=(${items[1,$NX_MAX_RESULTS]})
      fi
      ;;
    targets_full)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(<"$def" | jq -r '.graph.nodes[] | .name as $project | .data.targets | keys[] | $project + ":" + .' 2>/dev/null))
      else
        items=($(<"$def" | jq -r '.nodes[] | .name as $project | .data.targets | keys[] | $project + ":" + .' 2>/dev/null))
      fi
      ;;
  esac

  # Cache the results if we got any
  if [[ ${#items} -gt 0 ]]; then
    eval "${cache_key}=(\"\${items[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
    echo "${items[@]}" && ret=0
  fi

  return ret
}

# New function to get workspace items into an array variable (avoids echo/word splitting issues)
_get_workspace_items_array() {
  local item_type="$1" # "projects" or "targets" or "targets_full"
  local result_var="$2" # name of the result array variable
  integer ret=1
  local cache_key="nx_workspace_${item_type}"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check if we have cached items and they're still valid
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    eval "${result_var}=(\"\${(P@)cache_key}\")"
    return 0
  fi

  local def=$(_workspace_def)
  local nodes_path=$(_get_nodes_path "$def")
  local -a items=()

  case "$item_type" in
    projects)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(<$def | jq -r '.graph.nodes[] | .name'))
      else
        items=($(<$def | jq -r '.nodes[] | .name'))
      fi
      ;;
    targets)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(jq -r '[.graph.nodes[] | .data.targets | keys[]] | unique[]' "$def"))
      else
        items=($(jq -r '[.nodes[] | .data.targets | keys[]] | unique[]' "$def"))
      fi
      # Limit results for better performance
      if [[ ${#items} -gt $NX_MAX_RESULTS ]]; then
        items=(${items[1,$NX_MAX_RESULTS]})
      fi
      ;;
    targets_full)
      if [[ "$nodes_path" == ".graph.nodes" ]]; then
        items=($(<"$def" | jq -r '.graph.nodes[] | .name as $project | .data.targets | keys[] | $project + ":" + .' 2>/dev/null))
      else
        items=($(<"$def" | jq -r '.nodes[] | .name as $project | .data.targets | keys[] | $project + ":" + .' 2>/dev/null))
      fi
      ;;
  esac

  # Cache the results if we got any
  if [[ ${#items} -gt 0 ]]; then
    eval "${cache_key}=(\"\${items[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
    eval "${result_var}=(\"\${items[@]}\")"
    ret=0
  fi

  return ret
}

# Backward compatibility aliases
_workspace_projects() {
  local -a projects
  if _get_workspace_items_array "projects" projects; then
    echo "${projects[@]}"
  fi
}

_nx_workspace_targets() {
  local -a targets
  if _get_workspace_items_array "targets" targets; then
    echo "${targets[@]}"
  fi
}

# Unified completion function for workspace items
_complete_workspace_items() {
  local item_type="$1" # "projects" or "targets"
  [[ $PREFIX = -* ]] && return 1
  integer ret=1

  local cache_key="nx_list_${item_type}"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  local -a all_items=()
  local -a filtered_items=()

  if [[ "$item_type" == "projects" ]]; then
    _get_workspace_items_array "projects" all_items
  else
    # For targets, we need project:target format for _list_targets
    if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
      local -a cached_targets=("${(P@)cache_key}")
      # Filter cached results based on PREFIX if provided
      if [[ -n "$PREFIX" ]]; then
        for target in $cached_targets; do
          if [[ "$target" == ${PREFIX}* ]]; then
            filtered_items+=("$target")
            if [[ ${#filtered_items} -ge $NX_MAX_RESULTS ]]; then
              break
            fi
          fi
        done
      else
        # Take first N targets if no prefix
        filtered_items=(${cached_targets[1,$NX_MAX_RESULTS]})
      fi

      # Use compadd for better menu control when we have multiple items
      if [[ ${#filtered_items} -gt 0 ]]; then
        local expl
        _description project-targets expl 'Project targets'
        compadd "$expl[@]" -a filtered_items && ret=0
        return ret
      fi
    fi

    # Get full targets (project:target format)
    _get_workspace_items_array "targets_full" all_items

    # Cache for future use
    if [[ ${#all_items} -gt 0 ]]; then
      eval "${cache_key}=(\"\${all_items[@]}\")"
      _store_cache "$cache_key" "${cache_key}"
    fi
  fi

  # Filter items based on PREFIX and limit results
  if [[ ${#all_items} -gt $NX_MAX_RESULTS ]]; then
    if [[ -n "$PREFIX" ]]; then
      for item in $all_items; do
        if [[ "$item" == ${PREFIX}* ]]; then
          filtered_items+=("$item")
          if [[ ${#filtered_items} -ge $NX_MAX_RESULTS ]]; then
            break
          fi
        fi
      done
    else
      filtered_items=(${all_items[1,$NX_MAX_RESULTS]})
    fi
  else
    if [[ -n "$PREFIX" ]]; then
      for item in $all_items; do
        if [[ "$item" == ${PREFIX}* ]]; then
          filtered_items+=("$item")
        fi
      done
    else
      filtered_items=($all_items)
    fi
  fi

  # Use _describe for better menu completion behavior
  if [[ ${#filtered_items} -gt 0 ]]; then
    if [[ "$item_type" == "projects" ]]; then
      local expl
      _description nx-projects expl "Nx projects"
      compadd "$expl[@]" -a filtered_items && ret=0
    else
      local expl
      _description project-targets expl "Project targets"
      compadd "$expl[@]" -a filtered_items && ret=0
    fi
  fi

  return ret
}

# Simplified completion functions
_list_projects() {
  _complete_workspace_items "projects"
}

_list_targets() {
  _complete_workspace_items "targets"
}

_list_generators() {
  [[ $PREFIX = -* ]] && return 1
  integer ret=1
  local cache_key="nx_list_generators"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check if we have cached generators and they're still valid
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    local -a cached_generators=("${(P)cache_key[@]}")

    # Filter cached results based on PREFIX if provided
    local -a filtered_generators=()
    if [[ -n "$PREFIX" ]]; then
      for generator in $cached_generators; do
        if [[ "$generator" == ${PREFIX}* ]]; then
          filtered_generators+=("$generator")
          if [[ ${#filtered_generators} -ge $NX_MAX_RESULTS ]]; then
            break
          fi
        fi
      done
    else
      filtered_generators=(${cached_generators[1,$NX_MAX_RESULTS]})
    fi

    _describe -t nx-generators "Nx generators" filtered_generators && ret=0
    return ret
  fi

  local -a generators=()
  local -a plugins=()

  # Try to get plugins list with error handling
  local plugins_output=$(nx list 2>/dev/null)
  if [[ $? -eq 0 && -n "$plugins_output" ]]; then
    plugins=(${(f)"$(echo "$plugins_output" | awk '/Installed/,/Also available:/' | grep generators | awk -F ' ' '{print $1}')"})
  fi

  # If no plugins found, return gracefully
  if [[ ${#plugins} -eq 0 ]]; then
    return 1
  fi

  for p in $plugins; do
    local -a pluginGenerators=()
    # Try to get generators for this plugin with error handling
    local generators_output=$(nx list "$p" 2>/dev/null)
    if [[ $? -eq 0 && -n "$generators_output" ]]; then
      pluginGenerators=(${(f)"$(echo "$generators_output" | awk '/GENERATORS/,/EXECUTORS/' | grep ' : ' | awk -F " : " '{ print $1}' | awk '{$1=$1};1')"})
    fi

    for g in $pluginGenerators; do
      # Format generator as plugin:generator
      local generator="$p:$g"
      generators+=("$generator")
      # Limit total generators to prevent overwhelming the user
      if [[ ${#generators} -ge $NX_MAX_RESULTS ]]; then
        break 2
      fi
    done
  done

  # Cache all generators for future use
  if [[ ${#generators} -gt 0 ]]; then
    eval "${cache_key}=(\"\${generators[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
  fi

  # Filter generators based on PREFIX if provided
  local -a filtered_generators=()
  if [[ -n "$PREFIX" ]]; then
    for generator in $generators; do
      if [[ "$generator" == ${PREFIX}* ]]; then
        filtered_generators+=("$generator")
        if [[ ${#filtered_generators} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      fi
    done
    generators=($filtered_generators)
  fi

  # Run completion.
  _describe -t nx-generators "Nx generators" generators && ret=0
  return ret
}

_nx_commands() {
  [[ $PREFIX = -* ]] && return 1
  integer ret=1

  local cache_policy

  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  if ( [[ ${+_nx_subcommands} -eq 0 ]] || _cache_invalid nx_subcommands ) \
    && ! _retrieve_cache nx_subcommands
  then
    # Dynamically parse nx --help to get commands
    _nx_subcommands=()

    # Parse nx --help output to extract commands and descriptions
    local help_output=$(nx --help 2>/dev/null)
    if [[ $? -eq 0 && -n "$help_output" ]]; then
      # Extract commands section and parse each line
      local commands_section=$(echo "$help_output" | awk '/^Commands:$/,/^Options:$/ {print}' | grep -E '^\s+nx ')

      while IFS= read -r line; do
        if [[ -n "$line" ]]; then
          # Extract command name and description
          local cmd_line=$(echo "$line" | sed 's/^\s*nx\s*//' | sed 's/\s\s\+/ /')
          local cmd_name=$(echo "$cmd_line" | awk '{print $1}' | sed 's/\[.*\]//')
          local cmd_desc=$(echo "$cmd_line" | sed 's/^[^[:space:]]*\s*//')

          # Handle special cases for command names with arguments
          case "$cmd_name" in
            add)
              cmd_name="add"
              ;;
            generate)
              cmd_name="generate"
              ;;
            import)
              cmd_name="import"
              ;;
            migrate)
              cmd_name="migrate"
              ;;
            run)
              cmd_name="run"
              ;;
            login)
              cmd_name="login"
              ;;
            "<target>")
              # Skip the default target entry
              continue
              ;;
          esac

          # Escape colons in descriptions and add to array
          cmd_desc=$(echo "$cmd_desc" | sed 's/:/\\:/g')
          cmd_name=$(echo "$cmd_name" | sed 's/:/\\:/g')

          if [[ -n "$cmd_name" && -n "$cmd_desc" ]]; then
            _nx_subcommands+=("$cmd_name:$cmd_desc")
          fi
        fi
      done <<< "$commands_section"
    fi

    # Fallback to basic commands if parsing failed
    if [[ ${#_nx_subcommands} -eq 0 ]]; then
      _nx_subcommands=(
        'generate:Generate or update source code'
        'run:Run a target for a project'
        'run-many:Run target for multiple listed projects'
        'affected:Run target for affected projects'
        'graph:Graph dependencies within workspace'
        'list:Lists installed plugins and available plugins'
        'migrate:Creates a migrations file or runs migrations'
        'init:Adds Nx to any type of workspace'
        'repair:Repair any configuration that is no longer supported'
        'reset:Clears cached Nx artifacts and shuts down daemon'
        'report:Reports useful version numbers'
        'show:Show information about the workspace'
      )
    fi

    (( $#_nx_subcommands > 2 )) && _store_cache nx_subcommands _nx_subcommands
  fi

  local _nx_subcommands_and_targets=($(_nx_workspace_targets) $_nx_subcommands)

  # Run completion.
  _describe -t nx-commands "Nx commands" _nx_subcommands_and_targets && ret=0
  return ret
}

# Extract all unique executors from project graph
_nx_get_executors() {
  integer ret=1
  local cache_key="nx_executors"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check cache first
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  local def=$(_workspace_def)
  if [[ -f "$def" ]]; then
    local nodes_path=$(_get_nodes_path "$def")
    local -a executors=()
    if [[ "$nodes_path" == ".graph.nodes" ]]; then
      executors=($(jq -r '[.graph.nodes[] | .data.targets[]? | .executor] | unique | .[]' "$def" 2>/dev/null))
    else
      executors=($(jq -r '[.nodes[] | .data.targets[]? | .executor] | unique | .[]' "$def" 2>/dev/null))
    fi

    # Cache the results if we got any
    if [[ ${#executors} -gt 0 ]]; then
      eval "${cache_key}=(\"\${executors[@]}\")"
      _store_cache "$cache_key" "${cache_key}"
    fi

    echo "${executors[@]}" && ret=0
  fi
  return ret
}

# Extract executor options from project graph for a specific executor
_nx_get_executor_options() {
  local executor="$1"
  integer ret=1
  local cache_key="nx_executor_options_${executor//[^a-zA-Z0-9]/_}"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check cache first
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  local def=$(_workspace_def)
  if [[ -f "$def" ]]; then
    # Get all option keys for this executor across all projects
    local nodes_path=$(_get_nodes_path "$def")
    local -a all_options=()

    if [[ "$nodes_path" == ".graph.nodes" ]]; then
      all_options=($(jq -r --arg exec "$executor" '
        [.graph.nodes[] | .data.targets[]? | select(.executor == $exec) | .options // {} | keys[]] |
        unique |
        map("--" + . + "[" + . + "]") |
        .[]' "$def" 2>/dev/null))
    else
      all_options=($(jq -r --arg exec "$executor" '
        [.nodes[] | .data.targets[]? | select(.executor == $exec) | .options // {} | keys[]] |
        unique |
        map("--" + . + "[" + . + "]") |
        .[]' "$def" 2>/dev/null))
    fi

    # Limit results and cache them
    local -a limited_options=()
    if [[ ${#all_options} -gt $NX_MAX_RESULTS ]]; then
      limited_options=(${all_options[1,$NX_MAX_RESULTS]})
    else
      limited_options=($all_options[@])
    fi

    # Cache the results if we got any
    if [[ ${#limited_options} -gt 0 ]]; then
      eval "${cache_key}=(\"\${limited_options[@]}\")"
      _store_cache "$cache_key" "${cache_key}"
      echo "${limited_options[@]}" && ret=0
    fi
  fi
  return ret
}

# Map common target names to likely executors for better completion
_nx_get_target_executor() {
  local target="$1"
  local cache_key="nx_target_executor_${target//[^a-zA-Z0-9]/_}"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check cache first
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key}"
    return 0
  fi

  local def=$(_workspace_def)
  local executor=""
  if [[ -f "$def" ]]; then
    # Optimized: find the most common executor for this target name
    local nodes_path=$(_get_nodes_path "$def")
    if [[ "$nodes_path" == ".graph.nodes" ]]; then
      executor=$(jq -r --arg target "$target" '
        [.graph.nodes[] | .data.targets[$target]?.executor] |
        map(select(. != null)) |
        group_by(.) |
        max_by(length) |
        first // empty' "$def" 2>/dev/null)
    else
      executor=$(jq -r --arg target "$target" '
        [.nodes[] | .data.targets[$target]?.executor] |
        map(select(. != null)) |
        group_by(.) |
        max_by(length) |
        first // empty' "$def" 2>/dev/null)
    fi

    # Cache the result if we got one
    if [[ -n "$executor" ]]; then
      eval "${cache_key}=\"$executor\""
      _store_cache "$cache_key" "${cache_key}"
    fi
  fi

  echo "$executor"
}

# Get dynamic options for common Nx commands based on executors
_nx_get_dynamic_command_options() {
  local command="$1"
  local cache_key="nx_dynamic_${command}_options"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check if we have cached dynamic options and they're still valid
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  local -a dynamic_opts=()

  # Get all executors once and filter for the specific command
  local -a all_executors=($(_nx_get_executors))

  case "$command" in
    build|b)
      # Get options from build-related executors (limit to first few matches)
      local -a build_executors=(${(M)all_executors:#*build*} ${(M)all_executors:#*webpack*} ${(M)all_executors:#*browser*})
      build_executors=(${build_executors[1,3]}) # Limit to first 3 executors
      for executor in $build_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      done
      ;;
    test|t)
      # Get options from test-related executors
      local -a test_executors=(${(M)all_executors:#*jest*} ${(M)all_executors:#*cypress*} ${(M)all_executors:#*test*})
      test_executors=(${test_executors[1,3]}) # Limit to first 3 executors
      for executor in $test_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      done
      ;;
    serve|s)
      # Get options from serve-related executors
      local -a serve_executors=(${(M)all_executors:#*serve*} ${(M)all_executors:#*dev-server*})
      serve_executors=(${serve_executors[1,3]}) # Limit to first 3 executors
      for executor in $serve_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      done
      ;;
    lint|l)
      # Get options from lint-related executors
      local -a lint_executors=(${(M)all_executors:#*lint*} ${(M)all_executors:#*eslint*})
      lint_executors=(${lint_executors[1,3]}) # Limit to first 3 executors
      for executor in $lint_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      done
      ;;
    e2e|e)
      # Get options from e2e-related executors
      local -a e2e_executors=(${(M)all_executors:#*e2e*} ${(M)all_executors:#*cypress*} ${(M)all_executors:#*playwright*})
      e2e_executors=(${e2e_executors[1,3]}) # Limit to first 3 executors
      for executor in $e2e_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $NX_MAX_RESULTS ]]; then
          break
        fi
      done
      ;;
  esac

  # Remove duplicates, limit final results, and return
  dynamic_opts=(${(u)dynamic_opts[@]})
  local -a final_opts=()
  if [[ ${#dynamic_opts} -gt $NX_MAX_RESULTS ]]; then
    final_opts=(${dynamic_opts[1,$NX_MAX_RESULTS]})
  else
    final_opts=(${(u)dynamic_opts[@]})
  fi

  # Cache the results if we got any
  if [[ ${#final_opts} -gt 0 ]]; then
    eval "${cache_key}=(\"\${final_opts[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
  fi

  echo "${final_opts[@]}"
}

# Cache-aware wrapper for dynamic option parsing
_nx_get_command_options() {
  local command="$1"
  local cache_key="nx_${command}_options"
  local cache_policy

  # Set up cache policy
  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  # Check if we have cached options and they're still valid
  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  # Parse options dynamically
  local -a options=($(_nx_parse_command_options "$command"))

  # Cache the results if we got any
  if [[ ${#options} -gt 0 ]]; then
    eval "${cache_key}=(\"\${options[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
  fi

  echo "${options[@]}"
}

# Parse command-specific options from nx [command] --help
_nx_parse_command_options() {
  local command="$1"
  local -a parsed_options=()

  # Get help for the specific command
  local help_output=$(nx "$command" --help 2>/dev/null)
  if [[ $? -eq 0 && -n "$help_output" ]]; then
    # Extract options section
    local options_section=$(echo "$help_output" | awk '/^Options:$/,/^$|^[A-Z]/ {print}' | grep -E '^\s+(-|--)')

    while IFS= read -r line; do
      if [[ -n "$line" ]]; then
        # Clean up the line
        line=$(echo "$line" | sed 's/^\s*//')

        # Parse different option formats:
        # "  -c, --configuration  Description"
        # "      --some-option     Description"
        # "  -f, --force          Description [boolean]"

        local short_opt=""
        local long_opt=""
        local desc=""

        # Extract options and description
        if [[ "$line" =~ ^(-[a-zA-Z]),?\s+(--[a-zA-Z0-9-]+)\s+(.*)$ ]]; then
          # Format: -c, --configuration Description
          short_opt="${match[1]}"
          long_opt="${match[2]}"
          desc="${match[3]}"
        elif [[ "$line" =~ ^(--[a-zA-Z0-9-]+)\s+(.*)$ ]]; then
          # Format: --option Description
          long_opt="${match[1]}"
          desc="${match[2]}"
        elif [[ "$line" =~ ^(-[a-zA-Z])\s+(.*)$ ]]; then
          # Format: -o Description
          short_opt="${match[1]}"
          desc="${match[2]}"
        fi

        # Clean up description: remove type info in brackets, escape colons
        if [[ -n "$desc" ]]; then
          desc=$(echo "$desc" | sed 's/\[boolean\]$//' | sed 's/\[string\]$//' | sed 's/\[number\]$//' | sed 's/:/\\:/g' | sed 's/\s*$//')
        fi

        # Add to parsed options
        if [[ -n "$short_opt" && -n "$long_opt" ]]; then
          parsed_options+=("($short_opt $long_opt)"{$short_opt,$long_opt}"[$desc]")
        elif [[ -n "$long_opt" ]]; then
          parsed_options+=("$long_opt[$desc]")
        elif [[ -n "$short_opt" ]]; then
          parsed_options+=("$short_opt[$desc]")
        fi
      fi
    done <<< "$options_section"
  fi

  # Add dynamic executor options for certain commands
  local -a all_executors=($(_nx_get_executors))
  local -a dynamic_opts=()
  local max_executor_opts=15

  case "$command" in
    build|b)
      # Get options from build-related executors (limit to first few)
      local -a build_executors=(${(M)all_executors:#*build*} ${(M)all_executors:#*webpack*} ${(M)all_executors:#*browser*})
      build_executors=(${build_executors[1,2]}) # Limit to first 2 executors
      for executor in $build_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $max_executor_opts ]]; then
          break
        fi
      done
      ;;
    test|t)
      # Get options from test-related executors
      local -a test_executors=(${(M)all_executors:#*jest*} ${(M)all_executors:#*cypress*} ${(M)all_executors:#*test*})
      test_executors=(${test_executors[1,2]}) # Limit to first 2 executors
      for executor in $test_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $max_executor_opts ]]; then
          break
        fi
      done
      ;;
    serve|s)
      # Get options from serve-related executors
      local -a serve_executors=(${(M)all_executors:#*serve*} ${(M)all_executors:#*dev-server*})
      serve_executors=(${serve_executors[1,2]}) # Limit to first 2 executors
      for executor in $serve_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $max_executor_opts ]]; then
          break
        fi
      done
      ;;
    e2e)
      # Get options from e2e-related executors
      local -a e2e_executors=(${(M)all_executors:#*cypress*} ${(M)all_executors:#*e2e*})
      e2e_executors=(${e2e_executors[1,2]}) # Limit to first 2 executors
      for executor in $e2e_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $max_executor_opts ]]; then
          break
        fi
      done
      ;;
    lint)
      # Get options from lint-related executors
      local -a lint_executors=(${(M)all_executors:#*lint*} ${(M)all_executors:#*eslint*})
      lint_executors=(${lint_executors[1,2]}) # Limit to first 2 executors
      for executor in $lint_executors; do
        local -a exec_opts=($(_nx_get_executor_options "$executor"))
        dynamic_opts+=($exec_opts)
        if [[ ${#dynamic_opts} -ge $max_executor_opts ]]; then
          break
        fi
      done
      ;;
  esac

  # Combine parsed options with dynamic options (remove duplicates and limit total)
  parsed_options+=(${(u)dynamic_opts[@]})

  # Limit total options for performance
  local max_total_opts=50
  if [[ ${#parsed_options} -gt $max_total_opts ]]; then
    parsed_options=(${parsed_options[1,$max_total_opts]})
  fi

  echo "${parsed_options[@]}"
}

# Safe wrapper for _list_targets that prevents terminal crashes
_safe_list_targets() {
  # Try to call _list_targets with error handling
  if ! _list_targets 2>/dev/null; then
    # If _list_targets fails, try to get basic targets using unified function
    local -a fallback_targets=()

    # Try to use the unified function for simple target names
    if fallback_targets=($(_get_workspace_items "targets" 2>/dev/null)) && [[ ${#fallback_targets} -gt 0 ]]; then
      # Limit results for fallback
      if [[ ${#fallback_targets} -gt 10 ]]; then
        fallback_targets=(${fallback_targets[1,10]})
      fi
      _describe -t targets 'Available targets' fallback_targets
      return 0
    fi

    # Ultimate fallback - return common target names
    local -a common_targets=("build" "test" "lint" "serve" "e2e")
    _describe -t targets 'Common targets' common_targets
  fi
}

# Safe wrapper for _list_projects that prevents terminal crashes
_safe_list_projects() {
  # Try to call _list_projects with error handling
  if ! _list_projects 2>/dev/null; then
    # If _list_projects fails, try to get basic projects using unified function
    local -a fallback_projects=()

    # Try to use the unified function for project names
    if fallback_projects=($(_get_workspace_items "projects" 2>/dev/null)) && [[ ${#fallback_projects} -gt 0 ]]; then
      # Limit results for fallback
      if [[ ${#fallback_projects} -gt 10 ]]; then
        fallback_projects=(${fallback_projects[1,10]})
      fi
      _describe -t projects 'Available projects' fallback_projects
      return 0
    fi

    # Ultimate fallback - return empty completion
    return 1
  fi
}

_nx_command() {
  integer ret=1
  local -a _command_args opts_help opts_affected

  opts_help=("--help[Shows a help message for this command in the console]")
  opts_affected=(
    "--base[Base of the current branch (usually master).]:sha:"
    "--head[Latest commit of the current branch (usually HEAD).]:sha:"
    "--files[Change the way Nx is calculating the affected command by providing directly changed files, list of files delimited by commas.]:files:_files"
    "--uncommitted[Uncommitted changes.]"
    "--untracked[Untracked changes.]"
    "--version[Show version number.]"
    "--target[Task to run for affected projects.]:target:"
    "--output-style[Defines how Nx emits outputs tasks logs.]:output:"
    "--nx-bail[Stop command execution after the first failed task.]"
    "--nx-ignore-cycles[Ignore cycles in the task graph.]"
    "--parallel[Parallelize the command.]"
    "--all[All projects.]"
    "--exclude[Exclude certain projects from being processed.]:projects:_list_projects"
    "--runner[This is the name of the tasks runner configured in nx.json.]:runner:"
    "--configuration[This is the configuration to use when performing tasks on projects.]:configuration:"
    "--verbose[Print additional error stack trace on failure.]"
    "--skip-nx-cache[Rerun the tasks even when the results are available in the cache.]"
  )

  case "$words[1]" in
    (affected|affected:apps|affected:build|affected:libs|affected:e2e|affected:lint|affected:test|affected:graph|format|format:write|format:check|print-affected)
      _arguments $(_nx_arguments) \
        $opts_help \
        $opts_affected && ret=0
    ;;
    (b|build)
      # Use dynamic parsing combined with workspace executor options
      local -a build_opts=($(_nx_get_command_options "build"))
      local -a workspace_opts=($(_nx_get_dynamic_command_options "build"))
      local -a all_opts=($build_opts $workspace_opts)

      if [[ ${#all_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          ${(u)all_opts[@]} \
          ":project:_list_projects" && ret=0
      else
        # Minimal fallback
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[A named builder configuration.]:configuration:" \
          "--verbose[Display additional details about internal operations during execution.]" \
          ":project:_list_projects" && ret=0
      fi
    ;;
    (dep-graph|graph)
      # Use dynamic parsing for graph command
      local -a graph_opts=($(_nx_get_command_options "graph"))
      if [[ ${#graph_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $graph_opts && ret=0
      else
        # Fallback to basic options
        _arguments $(_nx_arguments) \
          $opts_help \
          "--file[Output file (e.g. --file=output.json or --file=dep-graph.html).]:file:_files" \
          "--focus[Use to show the dependency graph for a particular project.]:project:_list_projects" \
          "--exclude[List of projects to exclude from the dependency graph.]:projects:_list_projects:" && ret=0
      fi
    ;;
    (e|e2e)
      # Use dynamic parsing combined with workspace executor options
      local -a e2e_opts=($(_nx_get_command_options "e2e"))
      local -a workspace_opts=($(_nx_get_dynamic_command_options "e2e"))
      local -a all_opts=($e2e_opts $workspace_opts)

      if [[ ${#all_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          ${(u)all_opts[@]} \
          ":project:_list_projects" && ret=0
      else
        # Minimal fallback
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[A named builder configuration.]:configuration:" \
          "--watch[Recompile and run tests when files change.]" \
          ":project:_list_projects" && ret=0
      fi
    ;;
    (g|generate)
      # Use dynamic option parsing for generate command
      local -a generate_opts=($(_nx_get_command_options "generate"))
      if [[ ${#generate_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $generate_opts \
          ":generator:_list_generators" && ret=0
      else
        # Fallback to static options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "--version[Show version number.]" \
          "--defaults[When true, disables interactive input prompts for options with a default.]" \
          "--interactive[When false, disables interactive input prompts.]" \
          "(-d --dry-run)"{-d,--dry-run}"[When true, runs through and reports activity without writing out results.]" \
          "(-f --force)"{-f,--force}"[When true, forces overwriting of existing files.]" \
          ":generator:_list_generators" && ret=0
      fi
    ;;
    (l|lint)
      # Use dynamic parsing combined with workspace executor options
      local -a lint_opts=($(_nx_get_command_options "lint"))
      local -a workspace_opts=($(_nx_get_dynamic_command_options "lint"))
      local -a all_opts=($lint_opts $workspace_opts)

      if [[ ${#all_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          ${(u)all_opts[@]} \
          ":project:_list_projects" && ret=0
      else
        # Minimal fallback
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[The linting configuration to use.]:configuration:" \
          "--fix[Fixes linting errors (may overwrite linted files).]" \
          "--format[Output format.]:format:(prose json stylish verbose)" \
          ":project:_list_projects" && ret=0
      fi
    ;;
    (migrate)
      # Use dynamic parsing for migrate command
      local -a migrate_opts=($(_nx_get_command_options "migrate"))
      if [[ ${#migrate_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $migrate_opts \
          ":package:" && ret=0
      else
        # Fallback options
        _arguments $(_nx_arguments) \
          $opts_help \
          "--runMigrations[Run migrations.]:file:_files" \
          ":package:" && ret=0
      fi
    ;;
    (n|new)
      # Use dynamic parsing for new command
      local -a new_opts=($(_nx_get_command_options "new"))
      if [[ ${#new_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $new_opts \
          ":package:" && ret=0
      else
        # Fallback options
        _arguments $(_nx_arguments) \
          $opts_help \
          "--preset[What to create in the new workspace.]:preset:" \
          "--packageManager[The package manager used to install dependencies.]:pm:" \
          "(-d --dry-run)"{-d,--dry-run}"[When true, runs through and reports activity without writing out results.]" \
          ":package:" && ret=0
      fi
    ;;
    (run-many)
      # Use dynamic option parsing for run-many command
      local -a run_many_opts=($(_nx_get_command_options "run-many"))
      if [[ ${#run_many_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $run_many_opts && ret=0
      else
        # Fallback to static options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "--all[(deprecated) Run the target on all projects in the workspace]" \
          "--configuration[This is the configuration to use when performing tasks on projects]:configuration:" \
          "--exclude[Exclude certain projects from being processed]:projects:_list_projects:" \
          "--nx-bail[Stop command execution after the first failed task]" \
          "--nx-ignore-cycles[Ignore cycles in the task graph]" \
          "--output-style[Defines how Nx emits outputs tasks logs]:style:(dynamic static stream stream-without-prefixes)" \
          "(--parallel --maxParallel)"{--parallel,--maxParallel}"[Max number of parallel processes. (default is 3)]:count:" \
          "--projects[Projects to run (comma delimited).]:projects:_list_projects" \
          "--runner[Override the tasks runner in nx.json.]:runner:" \
          "(--skip-nx-cache --skipNxCache)"{--skip-nx-cache,--skipNxCache}"[Rerun the tasks even when the results are available in the cache.]" \
          "(-t --target --targets)"{-t=,--target=,--targets=}"[Task(s) to run for affected projects.]:target:" \
          "--version[Show version number.]" \
          "--verbose[Print additional error stack trace on failure.]" \
          && ret=0
      fi
    ;;
    (run|run-one)
      # Use dynamic parsing for run command
      local -a run_opts=($(_nx_get_command_options "run"))
      if [[ ${#run_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $run_opts \
          ":target:_list_targets" && ret=0
      else
        # Fallback to basic options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[A named builder configuration.]:configuration:" \
          "--verbose[Print additional error stack trace on failure.]" \
          ":target:_list_targets" && ret=0
      fi
      # Because run command use the following pattern my-project:executor:configuration,
      # we are concatening these 3 arguments as a single one because no clue how to deal with this special separator,
      # maybe one day someone will contribute with the solution, who knows.
    ;;
    (s|serve)
      # Use dynamic parsing combined with workspace executor options
      local -a serve_opts=($(_nx_get_command_options "serve"))
      local -a workspace_opts=($(_nx_get_dynamic_command_options "serve"))
      local -a all_opts=($serve_opts $workspace_opts)

      if [[ ${#all_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          ${(u)all_opts[@]} \
          ":project:_list_projects" && ret=0
      else
        # Fallback to static options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "--allowedHosts[List of hosts that are allowed to access the dev server.]:hosts:_hosts" \
          "--aot[Build using Ahead of Time compilation.]" \
          "--baseHref[Base url for the application being built.]:url:" \
          "--browserTarget[Target to serve.]:brower_target:" \
          "--commonChunk[Use a separate bundle containing code used across multiple bundles.]" \
          "(-c --configuration)"{-c=,--configuration=}"[A named builder configuration.]:configuration:" \
          "--deployUrl[URL where files will be deployed.]:deploy_url:" \
          "--disableHostCheck[Don't verify connected clients are part of allowed hosts.]" \
          "--hmr[Enable hot module replacement.]" \
          "--hmrWarning[Show a warning when the --hmr option is enabled.]" \
          "--host[Host to listen on.]:host:_hosts" \
          "--liveReload[Whether to reload the page on change, using live-reload.]" \
          "(-o --open)"{-o,--open}"[Opens the url in default browser.]" \
          "--optimization[Enables optimization of the build output.]" \
          "--poll[Enable and define the file watching poll time period in milliseconds.]" \
          "--port[Port to listen on.]:port:" \
          "--prod[When true, sets the build configuration to the production target, shorthand for \"--configuration=production\".]" \
          "--progress[Log progress to the console while building.]" \
          "--proxyConfig[Proxy configuration file.]:file:_files" \
          "--publicHost[The URL that the browser client (or live-reload client, if enabled) should use to connect to the development server. Use for a complex dev server setup, such as one with reverse proxies.]:public_host:" \
          "--servePath[The pathname where the app will be served.]:pathname:" \
          "--servePathDefaultWarning[Show a warning when deploy-url/base-href use unsupported serve path values.]" \
          "--sourceMap[Output sourcemaps.]" \
          "--ssl[Serve using HTTPS.]" \
          "--sslCert[SSL certificate to use for serving HTTPS.]:certificate:_files" \
          "--sslKey[SSL key to use for serving HTTPS.]:key:" \
          "--vendorChunk[Use a separate bundle containing only vendor libraries.]" \
          "--verbose[Adds more details to output logging.]" \
          "--watch[Rebuild on change.]" \
          ":project:_list_projects" && ret=0
      fi
    ;;
    (show)
      # Use dynamic parsing for show command
      local -a show_opts=($(_nx_get_command_options "show"))
      if [[ ${#show_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $show_opts \
          ":object:(projects)" && ret=0
      else
        # Fallback to basic options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "--verbose[Print additional error stack trace on failure.]" \
          ":object:(projects)" && ret=0
      fi
    ;;
    (t|test)
      # Use dynamic parsing combined with workspace executor options
      local -a test_opts=($(_nx_get_command_options "test"))
      local -a workspace_opts=($(_nx_get_dynamic_command_options "test"))
      local -a all_opts=($test_opts $workspace_opts)

      if [[ ${#all_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          ${(u)all_opts[@]} \
          ":project:_list_projects" && ret=0
      else
        # Fallback to static options if parsing fails
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-b --bail)"{-o,--open}"[Exit the test suite immediately after n number of failing tests (https://jestjs.io/docs/en/cli#bail).]" \
          "--ci[Whether to run Jest in continuous integration (CI) mode. This option is on by default in most popular CI environments. It will prevent snapshots from being written unless explicitly requested (https://jestjs.io/docs/en/cli#ci).]" \
          "--clearCache[Deletes the Jest cache directory and then exits without running tests. Will delete Jest's default cache directory. Note: clearing the cache will reduce performance.]" \
          "(-b --bail)"{-o,--open}"[Exit the test suite immediately after n number of failing tests (https://jestjs.io/docs/en/cli#bail).]" \
          "--commonChunk[Use a separate bundle containing code used across multiple bundles.]" \
          "(-coverage --code-coverage)"{-coverage,--code-coverage}"[Indicates that test coverage information should be collected and reported in the output (https://jestjs.io/docs/en/cli#coverage).]" \
          "(--color -colors)"{--color,-colors}"[Forces test results output color highlighting (even if stdout is not a TTY). Set to false if you would like to have no colors (https://jestjs.io/docs/en/cli#colors).]" \
          "--config[The path to a Jest config file specifying how to find and execute tests. If no rootDir is set in the config, the directory containing the config file is assumed to be the rootDir for the project. This can also be a JSON-encoded value which Jest will use as configuration.]:file:_files" \
          "(-c --configuration)"{-c=,--configuration=}"[A named builder configuration.]:configuration:" \
          "--coverageDirectory[The directory where Jest should output its coverage files.]:path:_path_files -/" \
          "--coverageReporters[A list of reporter names that Jest uses when writing coverage reports. Any istanbul reporter.]:reporter:" \
          "--detectOpenHandles[Attempt to collect and print open handles preventing Jest from exiting cleanly (https://jestjs.io/docs/en/cli.html#--detectopenhandles).]" \
          "--findRelatedTests[Find and run the tests that cover a comma separated list of source files that were passed in as arguments (https://jestjs.io/docs/en/cli#findrelatedtests-spaceseparatedlistofsourcefiles).]:files:_files" \
          "--jestConfig[The path of the Jest configuration. (https://jestjs.io/docs/en/configuration).]:file:_files" \
          "--json[Prints the test results in JSON. This mode will send all other test output and user messages to stderr (https://jestjs.io/docs/en/cli#json).]" \
          "(-w --max-workers)"{-w=,--max-workers=}"[Specifies the maximum number of workers the worker-pool will spawn for running tests. This defaults to the number of the cores available on your machine. Useful for CI. (its usually best not to override this default) (https://jestjs.io/docs/en/cli#maxworkers-num).]:count:" \
          "(-o --only-changed)"{-o,--only-changed}"[Attempts to identify which tests to run based on which files have changed in the current repository. Only works if you're running tests in a git or hg repository at the moment (https://jestjs.io/docs/en/cli#onlychanged).]" \
          "--outputFile[Write test results to a file when the --json option is also specified (https://jestjs.io/docs/en/cli#outputfile-filename).]:file:_files" \
          "--passWithNoTests[Will not fail if no tests are found (for example while using --testPathPattern.) (https://jestjs.io/docs/en/cli#passwithnotests).]" \
          "--prod[When true, sets the build configuration to the production target, shorthand for \"--configuration=production\".]" \
          "--reporters[Run tests with specified reporters. Reporter options are not available via CLI. Example with multiple reporters: jest --reporters=\"default\" --reporters=\"jest-junit\" (https://jestjs.io/docs/en/cli#reporters).]:reporters:" \
          "(-i --run-in-band)"{-i,--run-in-band}"[Run all tests serially in the current process (rather than creating a worker-pool of child processes that run tests). This is sometimes useful for debugging, but such use cases are pretty rare. Useful for CI. (https://jestjs.io/docs/en/cli#runinband).]" \
          "--showConfig[Print your Jest config and then exits (https://jestjs.io/docs/en/cli#--showconfig).]" \
          "--silent[Prevent tests from printing messages through the console (https://jestjs.io/docs/en/cli#silent).]" \
          "--testFile[The name of the file to test.]:filename:" \
          "--testLocationInResults[Adds a location field to test results. Used to report location of a test in a reporter. { \"column\": 4, \"line\": 5 } (https://jestjs.io/docs/en/cli#testlocationinresults).]" \
          "(-t --testNamePattern)"{-t=,--test-name-pattern=}"[Run only tests with a name that matches the regex pattern (https://jestjs.io/docs/en/cli#testnamepattern-regex).]:pattern:" \
          "--testPathPattern[An array of regexp pattern strings that is matched against all tests paths before executing the test (https://jestjs.io/docs/en/cli#testpathpattern-regex).]:path_pattern:" \
          "--testResultsProcessor[Node module that implements a custom results processor (https://jestjs.io/docs/en/configuration#testresultsprocessor-string).]:processor:" \
          "(-u --update-snapshot)"{-u,--update-snapshot}"[Use this flag to re-record snapshots. Can be used together with a test suite pattern or with --testNamePattern to re-record snapshot for test matching the pattern (https://jestjs.io/docs/en/cli#updatesnapshot).]" \
          "--useStderr[Divert all output to stderr.]" \
          "--verbose[Display individual test results with the test suite hierarchy. (https://jestjs.io/docs/en/cli#verbose).]" \
          "--watch[Watch files for changes and rerun tests related to changed files. If you want to re-run all tests when a file has changed, use the --watchAll option (https://jestjs.io/docs/en/cli#watch).]" \
          "--watchAll[Watch files for changes and rerun all tests when something changes. If you want to re-run only the tests that depend on the changed files, use the --watch option. (https://jestjs.io/docs/en/cli#watchall)]" \
          "--skipNxCache[Rerun the tasks even when the results are available in the cache.]" \
          ":project:_list_projects" && ret=0
      fi
    ;;
    (*)
      # Generic handler for any unrecognized commands - try dynamic parsing
      local command_name="${words[1]}"
      local -a dynamic_opts=($(_nx_get_command_options "$command_name"))
      if [[ ${#dynamic_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $dynamic_opts && ret=0
      else
        # Fallback to basic help and common options if command not recognized
        _arguments $(_nx_arguments) \
          $opts_help \
          "--version[Show version number.]" \
          "--verbose[Print additional error stack trace on failure.]" && ret=0
      fi
    ;;
  esac

  return ret
}

_nx_completion() {
  # Add top-level error handling to prevent terminal crashes
  {
    # In case no workspace found in current workind dir,
    # suggest creating a new workspace.
    _check_workspace_def
    if [[ $? -eq 1 ]] ; then
      local bold=$(tput bold 2>/dev/null || echo "")
      local normal=$(tput sgr0 2>/dev/null || echo "")
      _message -r "The current directory isn't part of an Nx workspace."
      _message -r ""
      _message -r "Create a workspace using npm init:"
      _message -r "${bold}npm init nx-workspace${normal}"
      _message -r "Create a workspace using yarn:"
      _message -r "${bold}yarn create nx-workspace${normal}"
      _message -r "Create a workspace using npx:"
      _message -r "${bold}npx create-nx-workspace${normal}" && return 0
    fi

    integer ret=1
    local curcontext="$curcontext" state _command_args opts_help

    opts_help=("--help[Shows a help message for this command in the console]")

    _arguments $(_nx_arguments) \
      $opts_help \
      "--version[Show version number]" \
      ": :->root_command" \
      "*:: :->command" && ret=0

    case $state in
      (root_command)
        _nx_commands && ret=0
      ;;
      (command)
        curcontext=${curcontext%:*:*}:nx-$words[1]:
        _nx_command && ret=0
      ;;
    esac

    return ret
  } 2>/dev/null || {
    # If anything fails catastrophically, provide a minimal fallback
    return 1
  }
}
compdef _nx_completion nx
