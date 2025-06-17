function dotlink --description "Move a file to a dotfiles category and create a symlink."

  # --- Argument Parsing ---
  if test (count $argv) -ne 2
    echo "Error: Invalid arguments." >&2
    echo "Usage: dotlink <source_file> <category>" >&2
    echo "Example: dotlink ~/.config/fish/config.fish fish" >&2
    return 1
  end

  set -l source_file $argv[1]
  set -l category $argv[2]
  set -l dotfiles_root "$HOME/dev/dotfiles"

  # --- Pre-checks ---
  set -l source_path (realpath "$source_file" 2>/dev/null)
  if not test -e "$source_path"
      echo "Error: Source file not found: $source_file" >&2
      return 1
  end

  if test -L "$source_path"
    echo "Info: '$source_file' is already a symbolic link."
    return 0
  end

  # --- Path Preparation ---
  set -l source_filename (basename "$source_path")
  set -l dest_dir "$dotfiles_root/$category"
  set -l dest_path "$dest_dir/$source_filename"

  # --- Execution ---
  echo "Dotfiles root: $dotfiles_root"
  echo "Category:      $category"
  echo "Source:        $source_path"
  echo "Destination:   $dest_path"
  echo ""

  if not test -d "$dest_dir"
      echo "Creating directory: $dest_dir"
      mkdir -p "$dest_dir"
  end

  if mv "$source_path" "$dest_path"; and ln -s "$dest_path" "$source_path"
    echo "✅ Success: Linked '$source_file' to category '$category'."
  else
    echo "❌ Error: Failed to process the file." >&2
    return 1
  end
end
