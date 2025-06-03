from prefect import flow, task

@task
def extract_data():
    print("Extracting data...")
    return {"data": [1, 2, 3]}

@task
def transform_data(data):
    print("Transforming data...")
    return [x * 2 for x in data["data"]]

@task
def load_data(transformed_data):
    print(f"Loading data: {transformed_data}")

@flow
def etl_pipeline():
    data = extract_data()
    transformed = transform_data(data)
    load_data(transformed)

if __name__ == "__main__":
    etl_pipeline()
