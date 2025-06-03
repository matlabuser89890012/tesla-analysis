from prefect import flow, get_run_logger


@flow(name="tesla-analysis")
def main_flow(run_mode: str = "dev", model_version: str = "v1"):
    logger = get_run_logger()
    logger.info(f"Running in {run_mode} mode with model version {model_version}")

if __name__ == "__main__":
    main_flow()
