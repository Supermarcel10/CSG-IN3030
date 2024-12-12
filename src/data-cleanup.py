import pandas as pd
import os


def get_file_size_mb(file_path):
    size_bytes = os.path.getsize(file_path)
    return size_bytes / (1024 * 1024)  # B -> KB -> MB


def print_stats(len_original_rows, len_processed_rows, original_size_mb, processed_size_mb):
    len_removed_rows = len_original_rows - len_processed_rows
    removed_rows_perc = len_removed_rows / len_original_rows * 100

    size_diff = original_size_mb - processed_size_mb
    size_diff_perc = size_diff / original_size_mb * 100

    print(f"""
Processing complete!

Rows:
{len_processed_rows}/{len_original_rows} ({len_removed_rows} rows / {removed_rows_perc:.1f}% removed)

File size:
{processed_size_mb:.2f}M/{original_size_mb:.2f}M ({size_diff:.2f}M / {size_diff_perc:.1f}% reduction)
""")


def cleanup(input_file, output_file):
    try:
        original_size_mb = get_file_size_mb(input_file)

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

        processed_size_mb = get_file_size_mb(output_file)

        print_stats(len_original_rows, len(df), original_size_mb, processed_size_mb)

    except FileNotFoundError:
        print(f"Error: Could not find the input file '{input_file}'")
    except KeyError:
        print("Error: Could not find 'Observation' column in the CSV file")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    cleanup("../data/RM080-2021-1.csv", "../data/minified.csv")
