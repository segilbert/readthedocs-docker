NAME =	frozenbytes/readthedocs

build:
	docker build -t $(NAME) .

release:
	docker push $(NAME)

compose-up:
	docker-compose up -d --no-recreate
compose-up-rc:
	docker-compose up -d 
run:
	docker-compose run --service-ports --rm readthedocs
