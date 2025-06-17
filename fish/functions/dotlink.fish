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
  # If the file is already a symlink, do nothing.
  # To rebuild the manifest for existing links, it's safest to
  # delete the manifest file and re-run this command for all files.
  if test -L "$source_file"
    echo "Info: '$source_file' is already a symbolic link."
    return 0
  end

  # Check if the source file exists.
  set -l source_path (realpath "$source_file" 2>/dev/null)
  if not test -e "$source_path"
      echo "Error: Source file not found: $source_file" >&2
      return 1
  end

  # --- Path Preparation ---
  set -l source_filename (basename "$source_path")
  set -l dest_dir "$dotfiles_root/$category"
  set -l dest_path "$dest_dir/$source_filename"

  # --- Execution ---
  echo "Processing link..."
  echo "  Source:      $source_path"
  echo "  Destination: $dest_path"
  echo ""

  if not test -d "$dest_dir"
      mkdir -p "$dest_dir"
  end

  if mv "$source_path" "$dest_path"; and ln -s "$dest_path" "$source_path"
    # --- Record to Manifest ---
    set -l manifest_file "$dotfiles_root/manifest.tsv"
    set -l repo_relative_path "$category/$source_filename"

    # Convert the absolute path to a portable format using a tilde (~).
    set -l portable_path (string replace -- "$HOME" "~" "$source_path")

    # Remove any old entry for the same path to prevent duplicates.
    if test -e "$manifest_file"
      set -l temp_manifest (mktemp)
      grep -v -e "\t$portable_path\$" "$manifest_file" > "$temp_manifest"
      mv "$temp_manifest" "$manifest_file"
    end

    # Append the new entry to the manifest.
    echo -e "$repo_relative_path\t$portable_path" >> "$manifest_file"

    echo "✅ Success: Linked '$source_file' and recorded to manifest."
  else
    echo "❌ Error: Failed to process the file." >&2
    return 1
  end
end
