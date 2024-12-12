import pandas as pd
import json
import os


def get_file_size_mb(file_path):
    size_bytes = os.path.getsize(file_path)
    return size_bytes / (1024 * 1024)  # B -> KB -> MB


def print_stats(name="", len_original_lines=0, len_processed_lines=0, original_size_mb=0.0, processed_size_mb=0.0):
    if name == "":
        print(f"\nProcessing complete!")
    else:
        print(f"\n{name} complete!")

    if (len_original_lines != 0) & (len_processed_lines != 0):
        len_removed_lines = len_original_lines - len_processed_lines
        removed_lines_perc = len_removed_lines / len_original_lines * 100

        print(f"Lines: {len_processed_lines}/{len_original_lines} ({len_removed_lines} lines / {removed_lines_perc:.1f}% removed)")

    if (original_size_mb != 0) & (processed_size_mb != 0):
        size_diff = original_size_mb - processed_size_mb
        size_diff_perc = size_diff / original_size_mb * 100

        print(f"File size: {processed_size_mb:.2f}M/{original_size_mb:.2f}M ({size_diff:.2f}M / {size_diff_perc:.1f}% reduction)")


def cleanup_csv(input_file, output_file):
    try:
        df = pd.read_csv(input_file)
        len_original_rows = len(df)

        # Rename colums for easier workability
        df = df.rename(columns={
            "Lower tier local authorities Code": "authority_id",
            "Lower tier local authorities": "authority_name",
            "Proficiency in English language (4 categories) Code": "english_proficiency",
            "Industry (current) (9 categories) Code": "industry",
            "Highest level of qualification (7 categories) Code": "qualification",
            "Household deprived in the employment dimension (3 categories) Code": "deprivation",
            "Observation": "count"
        })

        # Remove empty observations
        df = df[df["count"] != 0]

        # Remove unnecessary columns (the code values can be used instead)
        df = df.drop(columns=[
            "Proficiency in English language (4 categories)",
            "Industry (current) (9 categories)",
            "Highest level of qualification (7 categories)",
            "Household deprived in the employment dimension (3 categories)"
        ])

        # Remove invalid data (not applicables)
        df = df[~(
                (df["english_proficiency"] == -8) |
                (df["industry"] == -8) |
                (df["qualification"] == -8)
        )]

        df.to_csv(output_file, index=False)

        original_size_mb = get_file_size_mb(input_file)
        processed_size_mb = get_file_size_mb(output_file)

        print_stats("Cleanup CSV", len_original_rows, len(df), original_size_mb, processed_size_mb)

    except FileNotFoundError:
        print(f"Error: Could not find the input file '{input_file}'")
    except KeyError:
        print("Error: Could not find 'Observation' column in the CSV file")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


def cleanup_json(input_file, output_file):
    def remove_properties(obj):
        if isinstance(obj, dict):
            obj.pop("properties", None)

            for value in obj.values():
                remove_properties(value)
        elif isinstance(obj, list):
            for item in obj:
                remove_properties(item)
        return obj

    with open(input_file, "r") as f:
        data = json.load(f)

    # Strip properties using recursion
    stripped_data = remove_properties(data)

    with open(output_file, "w") as f:
        json.dump(stripped_data, f)

    original_size_mb = get_file_size_mb(input_file)
    processed_size_mb = get_file_size_mb(output_file)

    print_stats("Cleanup JSON", original_size_mb=original_size_mb, processed_size_mb=processed_size_mb)


if __name__ == "__main__":
    cleanup_csv("../data/RM080-2021-1.csv", "../data/minified-RM080-2021-1.csv")
    cleanup_json("../data/EN_topo.json", "../data/minified-EN_topo.json")
