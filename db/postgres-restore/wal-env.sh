RUN echo "SECRET_KEY" | sudo tee  /etc/wal-e.d/env/prod/AWS_SECRET_ACCESS_KEY
RUn echo "KEY_ID" | sudo tee /etc/wal-e.d/env/prod/AWS_ACCESS_KEY_ID
RUN echo "S3_PREFIX" | sudo tee /etc/wal-e.d/env/prod/WALE_S3_PREFIX
