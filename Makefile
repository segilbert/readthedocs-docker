NAME =	vassilvk/readthedocs
#NAME =	frozenbytes/readthedocs

build:
	docker build -tg $(NAME) .

release:
	docker push $(NAME)

compose-up:
	docker-compose up -d --no-recreate
	docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" readthedocs
compose-up-rc:
	docker-compose up -d 
	docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" readthedocs
run:
	docker-compose run --service-ports --rm readthedocs
	docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" readthedocs
run-baseline:
	#docker run -d -it -p 8000:8000 -e "RTD_PRODUCTION_DOMAIN=localhost:8000" -v ~/readthedocs.org:/www/readthedocs.org --name readthedocs vassilvk/readthedocs
	docker run -d -it -p 8000:8000 -e "RTD_PRODUCTION_DOMAIN=localhost:8000" --name readthedocs vassilvk/readthedocs
	docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" readthedocs


	