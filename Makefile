default:
	docker build -t atyenoria/laravel-base . & docker run -it atyenoria/laravel-base zsh
shell:
	docker run -it atyenoria/laravel-base zsh
build:
	docker build -t atyenoria/laravel-base .