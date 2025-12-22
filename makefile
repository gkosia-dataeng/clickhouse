dwh-up:
	@cd local_env && \
	docker-compose up -d

dwh-dw:
	@cd local_env && \
	docker-compose down