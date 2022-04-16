from pathlib import Path
import shutil


def main():
    src_path = Path(input("Enter path to markdown file: "))
    assert src_path.exists()

    dst_filename = input(f"Enter new filename: ")
    assert dst_filename.endswith(src_path.suffix)

    dst_path = src_path.parent / dst_filename
    shutil.move(
        src=src_path,
        dst=dst_path,
    )

    src_dirpath = src_path.parent / f"{src_path.stem}.assets"
    dst_dirpath = dst_path.parent / f"{dst_path.stem}.assets"
    if not src_dirpath.exists():
        return

    shutil.move(
        src=src_dirpath,
        dst=dst_dirpath,
    )
    adapt_asset_links(dst_path, src_dirpath, dst_dirpath)

def adapt_asset_links(dst_path, src_dirpath, dst_dirpath):
    with open(dst_path, "r") as f:
        src_lines = f.readlines()

    dst_lines = [l.replace(src_dirpath.name, dst_dirpath.name) for l in src_lines]
    with open(dst_path, "w") as f:
        f.writelines(dst_lines)


if __name__ == "__main__":
    main()
