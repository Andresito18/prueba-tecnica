# PRUEBA TECNICA
## _SYSADMIN_

#### RTA: 

###### JAVA APLICATION

A nivel de applicacion de java monitoriaria que la aplicacion este corriendo bien tambien metricas a las rutas de la aplicacion si las solicitudes estan repondiendo correctamente.

###### MONGODB

En la base de datos de mongodb me encargaria de monitoriar la capacidad de la instancia en la corre mongo tambien tendria las metricas del estatus de las transacciones que se realizan en mongo , otra seria las conexion al cluster de mongodb.

###### RABBIT MQ

En el broker de rabbit monitoriaria temas de hardware de los nodos que se usan, el medicion del rendimiento de las colas tambien de la conexiones al cluster otras metricas serian de los mensajes intercambiados en un canal y en una cola. Y por ultimo del rendimiento del mensaje para el clúster.

###### KAFKA

para kafka mediria Velocidad de reducción de las réplicas en sincronización, velocidad de expansión de las réplicas en sincronización.

herramientas que utilizaria:

- Prometheus
- Grafana
- fluentd
- Datadog
- New Relic

## _NETWORKING + SYSADMIN + CLOUD_

Para poder correr este codigo de terraform necesitas tener las ultimas versiones de este.


con estos comandos vas a poder a ejecutar el template de terraform:

```sh
cd terraform
```

```sh
terraform init 
```


```sh
terraform plan
```

```sh
terraform apply 
```

NOTA: Debes tener los secrets de aws para poner a correr el cluster y una cuenta de atlas mongodb. 

## _DOCKER + TROUBLESHOOTING_

En este paso hice un cambio de la configuracion del dockerfile esta funcionando correctamente corriendo los siguientes comandos.


```sh
cd docker-troubleshooting
```

```sh
docker build -t appflask .
```

```sh
docker run -d -p 80:80 appflask
```

Pasos o cosas que agregaria para ciertas mejoras:

- Hacer pruebas unitarias al codigo para validar la calidad del codigo que se sube.
- Esta imagen esta construida con una imagen que ya tiene python, gunicorn ya para solo colocar la app que tu quieres usar.
- Tambien correria pruebas de codigo estatico con sonarqube.

## _KUBERNETES_

Para poner a funcionar esta parte se necesita poder tener docker registry la url es 

 [docker-registry](https://hub.docker.com/r/andyayala20/prueba-tecnica)


en este 