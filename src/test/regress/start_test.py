"""Run the pg_regress test suite with a selected list for spanner.
"""

import os
import sys
import subprocess
import time


current_script_cwd = os.getcwd()
print(f"Current working directory of Python script: {current_script_cwd}")

def execute_cmd(command, subprocess_dir="./"):
    try:
        # Execute the command and capture output
        # capture_output=True captures stdout and stderr
        # text=True decodes output as text using default encoding
        proc = subprocess.Popen(command,
                                cwd=subprocess_dir,
                                shell=True,
                                text=True,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)

        print("Command Output:")
        stdout = []
        while True:
            line = proc.stdout.readline()
            if not line:
                break
            stdout.append(line)
            print(line.rstrip())

        # Access any error output
        _, stderr = proc.communicate()
        if stderr:
            print("\nError Output:")
            print(stderr)

        # Access the exit code
        print(f"\nExit Code: {proc.returncode}")
        return "".join(stdout)

    except subprocess.CalledProcessError as e:
        # Handle errors if the command returns a non-zero exit code
        print(f"Error executing command: {e}")
        print(f"Stderr: {e.stderr}")
    except FileNotFoundError:
        print(f"Error: Command '{command}' not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def main():
    """Main function to run the pg_regress test suite."""
    # 1. configure (at project root directory)
    execute_cmd("./configure --without-icu --without-readline --without-zlib", "../../..")
    # 2. make pg_regress binary
    execute_cmd("make")
    # 3. start pgadapter + emulator container
    execute_cmd("docker pull gcr.io/cloud-spanner-pg-adapter/pgadapter-emulator")
    container_id = execute_cmd("docker run -d -p 5432:5432 gcr.io/cloud-spanner-pg-adapter/pgadapter-emulator")
    print(f"Emulator container ID: {container_id}")
    print("Program execution paused for 5 seconds...")
    time.sleep(5)

    # 4. test_setup.sql
    execute_cmd("./pg_regress --bindir=/usr/bin --host=127.0.0.1 --port=5432 --user=root --dbname=test-database --use-existing test_setup")
    # 5. load test data
    execute_cmd("cat data/onek.data | psql 'postgresql://root@127.0.0.1:5432/test-database?sslmode=disable' -c \"COPY onek (unique1, unique2, two, four, ten, twenty, hundred, thousand, twothousand, fivethous, tenthous, odd, even, stringu1, stringu2, string4) FROM STDIN\"")
    execute_cmd("cat data/tenk.data | psql 'postgresql://root@127.0.0.1:5432/test-database?sslmode=disable' -c \"SET SPANNER.AUTOCOMMIT_DML_MODE='PARTITIONED_NON_ATOMIC'; COPY tenk1 (unique1, unique2, two, four, ten, twenty, hundred, thousand, twothousand, fivethous, tenthous, odd, even, stringu1, stringu2, string4) FROM STDIN\"")
    # 6. run pg_regress test
    testcases = [os.path.splitext(filename)[0].removeprefix("sql/") for filename in execute_cmd("ls sql/*.sql").split("\n") if filename != ""]
    # We already ran this before.
    testcases.remove("test_setup")
    print(f"Running sql files: {testcases}")
    testcases_string = " ".join(testcases)
    execute_cmd(f"./pg_regress --bindir=/usr/bin --host=127.0.0.1 --port=5432 --user=root --dbname=test-database --use-existing {testcases_string}")
    # 7. compare results (json format) to get a score
    #execute_cmd(f"python compare_results.py expected/ results/"
    # 8. stop pg_adapter & emulator container
    execute_cmd(f"docker stop {container_id}")

if __name__ == "__main__":
    main()
