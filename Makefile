default:
	docker build -t atyenoria/laravel-base . & docker run -it atyenoria/laravel-base zsh
s:
	docker run -it atyenoria/laravel-base zsh
b:
	docker build -t atyenoria/laravel-base .