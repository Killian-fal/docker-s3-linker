# Docker S3 Linker

This docker image lets you link an S3 (or compatible) bucket to a local folder, enabling you to manage local files as if they were stored in the cloud (or vice versa). The combination with symlink file can be very powerful.

## Configuration

### AWS configuration
Configuration of the aws cli is identical to that explained in the [documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

To do this, you need to create a `.aws/credentials` file and a `.aws/config` file:
```shell
cp .aws/credentials.sample .aws/credentials
cp .aws/config.sample .aws/config
```

An example of configuration with Cloudfare R2 (which is compatible with AWS S3 cli) is provided in the `.aws-sample/cloudfare-r2` folder.

### Container configuration

To configure the container, you need to create a `.env` file at the root of the project. 

```shell
cp .env.sample .env
```

These are the environment variables in the `.env` :
- `ACTIVE_PROFILE`: The AWS profile used
- `SYNC_ARGUMENTS`: The synchronization arguments for the `aws s3 sync` command ([see doc](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html))
- `DELAY`: The delay in seconds between each synchronization
- `LINK_FROM_S3_BUCKET`: The name of the S3 buckets that will be linked to the local folder (e.g.: LINK_FROM_S3_BUCKET=bucket1;bucket2)
- `LINK_TO_S3_BUCKET`: The name of S3 buckets that will be updated from a local folder (ex: LINK_TO_S3_BUCKET=bucket3)
- `DEBUG`: Debug mode to display detailed logs

The variables `LINK_FROM_S3_BUCKET` and `LINK_TO_S3_BUCKET` are used to specify the direction of synchronization. If you want to link an S3 bucket to a local folder, use `LINK_FROM_S3_BUCKET`. If you want to update an S3 bucket from a local folder, use `LINK_TO_S3_BUCKET`.

Finally, you need to configure the `docker-compose.yml` file to define the volumes shared between the container and your computer.

Example: 
```yaml
   [...]
   volumes:
      - ./.aws:/root/.aws
      - ./local-file-test:/mnt/buckets/bucket1
      - ./yes-no-whyy:/mnt/buckets/bucket2
      - /home/debian/noooo:/mnt/buckets/bucket3
    [...]
```

**OPTIONAL**: You can launch the container in arm64:
```yaml
   [...]
   build:
    context: .
    dockerfile: Dockerfile
    args:
      - AWS_CLI_ARCH_SUFFIX=aarch64 
   platform: linux/arm64/v8
   [...]
``` 

## How to run the project ?

Clone the repo:
```shell
git clone git@github.com:Killian-fal/docker-s3-linker.git
cd docker-s3-linker
# Configure the container...
```

Have docker installed and then run: 
```shell
docker compose up --build -d
```

To stop the container, use:
```shell
docker compose down
```

## Samples
A list of examples is available [here](https://github.com/Killian-fal/docker-s3-linker/tree/main/samples) to show the possible uses.

1. **classic:** version with only 1 LINK_FROM_S3_BUCKET
2. **complex:** version with 2 LINK_FROM_S3_BUCKET and 1 LINK_TO_S3_BUCKET
3. **with-cloudfare-r2:** complex version with cloudfare R2 configuration

## TODO
- tests
- CI/CD

## License

This project is Open Source software released under the [MIT license.](https://opensource.org/license/mit)