step1:
add new domian and update deploy-hostinger.yml

step2:
add new domain and update docker-compose.yml

step3:
  check proxy: docker network inspect proxy
  if not new domain then : docker network connect proxy xxx
  then check again : docker network inspect proxy
  then restart procy: docker restart global-nginx
<img width="729" height="696" alt="docker-nginx execution order" src="https://github.com/user-attachments/assets/f75a425b-5960-4396-8fdc-599650425fff" />

