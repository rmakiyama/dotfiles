function dotdeploy --description "Deploy dotfiles by creating symlinks based on the manifest."

  # NOTE: Set your dotfiles repository path here.
  set -l dotfiles_root "$HOME/dev/dotfiles"
  set -l manifest_file "$dotfiles_root/manifest.tsv"

  if not test -e "$manifest_file"
    echo "Error: Manifest file not found at '$manifest_file'" >&2
    return 1
  end

  echo "🚀 Starting dotfiles deployment..."

  # Read the manifest file line by line.
  while read -l line
    # Split the line by a tab character into two parts:
    # 1. The relative path within the dotfiles repository.
    # 2. The portable, tilde-based path for the destination.
    set -l parts (string split \t -- "$line")
    set -l repo_path $parts[1]
    set -l portable_path $parts[2]

    # Expand the portable path (e.g., "~/.config/fish") to a full, absolute path.
    set -l link_target (string replace -r '^~' -- "$HOME" "$portable_path")

    set -l source_in_repo "$dotfiles_root/$repo_path"

    # --- Symlinking Process ---

    # 1. Check if the source file exists in the dotfiles repository.
    if not test -e "$source_in_repo"
      echo "⚠️ Skipping: Source file not found in dotfiles repo: $source_in_repo"
      continue
    end

    # 2. Create parent directories for the target if they don't exist.
    set -l target_parent_dir (dirname "$link_target")
    if not test -d "$target_parent_dir"
      mkdir -p "$target_parent_dir"
    end

    # 3. Handle cases where a file or link already exists at the target location.
    if test -e "$link_target"
      # If it's already a symlink, assume it's correct and do nothing.
      if test -L "$link_target"
         echo "➡️ Skipping: Link already exists at $link_target"
         continue
      # If it's a regular file (not a link), back it up before creating the new link.
      else
         set -l backup_path "$link_target.bak"
         echo "↪️ Backing up existing file: $link_target -> $backup_path"
         mv "$link_target" "$backup_path"
      end
    end

    # 4. Create the symbolic link.
    echo "🔗 Linking: $source_in_repo -> $link_target"
    ln -s "$source_in_repo" "$link_target"

  end < "$manifest_file"

  echo "✅ Deployment complete!"
end
