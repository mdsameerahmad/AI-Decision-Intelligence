import os
import uuid
from app.core.settings import settings


class DatasetStorage:

    @staticmethod
    def save_file(upload_file):

        file_id = str(uuid.uuid4())

        filename = f"{file_id}_{upload_file.filename}"

        storage_path = settings.DATASET_STORAGE_PATH

        os.makedirs(storage_path, exist_ok=True)

        file_path = os.path.join(storage_path, filename)

        with open(file_path, "wb") as buffer:
            buffer.write(upload_file.file.read())

        return file_path

    @staticmethod
    def list_datasets():

        storage_path = settings.DATASET_STORAGE_PATH

        if not os.path.exists(storage_path):
            return []

        return os.listdir(storage_path)