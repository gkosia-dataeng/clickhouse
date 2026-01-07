# ClickHouse Local Environment

The local_env provides a Dockerized environment to practice ClickHouse workloads.

## Authentication
Users are defined in the users.xml file.

- Username: admin
- Password: MyStrongPassword

## Web Access
ClickHouse HTTP interface (used by web UIs and tools) is available at:

http://localhost:8123/

## Password Hash Generation
To generate the SHA-256 hash for the password, run:

echo -n "MyStrongPassword" | sha256sum

## users.xml Configuration Notes

users
- Defines usernames
- Associates users with profiles and quotas
- Controls allowed network access

profile
- Defines resource limits (memory, threads, etc.)

quota
- Defines query limits (rate, execution time, rows, etc.)

networks
- Specifies allowed IP addresses

access_management
- When set to 1, allows the user to manage users, roles, and grants



## MinIO (Local Cloud Storage Emulation)

To emulate a cloud environment locally, the setup deploys an additional container running **MinIO**, which acts as an S3-compatible object storage service.

### Startup Behavior
- When the environment starts, a MinIO container is launched automatically.
- A bucket named **raw-data** is created during startup.

### Accessing MinIO
You can access the MinIO web console using the following details:

- **URL:** http://localhost:9091/
- **Username:** minIOuser
- **Password:** minIOpass

### Access from ClickHouse
The ClickHouse container can access MinIO in the same way it would access an S3 bucket.

Example SQL:

    DESC s3('http://minIO:9000/raw-data/uk_prices.csv.zst');

This allows ClickHouse to directly query files stored in the MinIO bucket using the s3 table function.
