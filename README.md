# File System Manager API

## Description

Develop a model layer for a file system persisted in a SQL database where it's possible to create directories and files. The directories can contain subdirectories and files. The file contents can be persisted as blob, S3, or on disk.

The solution should be written primarily in Ruby using the Ruby on Rails framework.

## Requirements

- Docker and Docker Compose
- Ruby 3.4.3

Optional
- jq (`sudo apt-get install jq` or `brew install jq`)
- curl

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd ruby-dev-test-1
```

2. Build the Docker image:
```bash
docker compose build
```

3. Setup the database:
```bash
docker compose run app bin/rails db:setup
```

## Running the Application

Start the application:
```bash
docker compose up
```

Running migrations
```bash
docker compose run app bin/rails db:migrate
```

The API will be available at `http://localhost:1234`

## API Endpoints

### Directories

#### List Root Directories

Returns all root-level directories.

```bash
curl -X GET http://localhost:1234/directories | jq
```

#### Get Specific Directory

Returns a specific directory and its complete subtree.

```bash
curl -X GET http://localhost:1234/directories/:id | jq
```

#### Create Directory

Creates a new directory. Set `parent_id` to create a subdirectory.

```bash
# Create root directory
curl -X POST http://localhost:1234/directories \
  -H "Content-Type: application/json" \
  -d '{
    "directory": {
      "name": "New Root Directory",
      "parent_id": null
    }
  }' | jq

# Create subdirectory
curl -X POST http://localhost:1234/directories \
  -H "Content-Type: application/json" \
  -d '{
    "directory": {
      "name": "Subdirectory",
      "parent_id": 1
    }
  }' | jq
```

Delete a specific directory.

```bash
curl -X DELETE http://localhost:1234/directories/:id | jq
```

### Files

#### Upload Files

Upload one or multiple files to a directory.

```bash
# Upload single file
(echo "File 1 content" > /tmp/file1.txt && \
 curl -X POST http://localhost:1234/directories/:directory_id/files \
   -F "files[]=@/tmp/file1.txt" | jq && \
 rm /tmp/file1.txt)

# Upload multiple files
(echo "File 1 content" > /tmp/file1.txt && \
 echo "File 2 content" > /tmp/file2.txt && \
 curl -X POST http://localhost:1234/directories/:directory_id/files \
   -F "files[]=@/tmp/file1.txt" \
   -F "files[]=@/tmp/file2.txt" | jq && \
 rm /tmp/file1.txt /tmp/file2.txt)
```

#### Delete File

Delete a specific file from a directory.

```bash
curl -X DELETE http://localhost:1234/directories/:directory_id/files/:id | jq
```

## Running Tests

1. Install development dependencies:
```bash
docker compose run app bundle install
```

2. Run the test suite:
```bash
docker compose run -e RAILS_ENV=test app bash -c "bin/rails db:migrate && bundle exec rspec"
```

## Troubleshooting

1. Remove all containers and volumes:
```bash
docker compose down -v
```