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
