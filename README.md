step1:
add new domian and update deploy-hostinger.yml

step2:
add new domain and update docker-compose.yml

step3:
  check proxy: docker network inspect proxy
  if not new domain then : docker network connect proxy xxx
  then check again : docker network inspect proxy
  then restart procy: docker restart global-nginx
<img width="1119" height="871" alt="docker-nginx 执行顺序" src="https://github.com/user-attachments/assets/f2b1e0f6-25ce-4dc4-8f27-13fb76fd083c" />
