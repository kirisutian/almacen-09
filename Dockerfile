# ============================================================
# ETAPA 1: BUILD
# ============================================================

# Usa una imagen que ya contiene:
# - Maven 3.9 para compilar el proyecto
# - Eclipse Temurin JDK 17 para ejecutar Java durante el build
#
# "AS build" le pone el nombre "build" a esta etapa,
# para poder copiar archivos desde ella posteriormente.
FROM maven:3.9-eclipse-temurin-17 AS build
# Define /almacen-app como directorio de trabajo dentro
# del contenedor de build.
#
# A partir de aquí, los comandos COPY, RUN, etc. trabajarán
# principalmente dentro de este directorio.
WORKDIR /almacen-app
# Copia únicamente el pom.xml del proyecto.
#
# Se hace antes de copiar el código fuente para aprovechar
# la caché de Docker.
#
# Si el pom.xml no cambia, Docker puede reutilizar las capas
# relacionadas con las dependencias aunque cambie el código Java.
COPY pom.xml .
# Descarga las dependencias definidas en pom.xml.
#
# - dependency:go-offline: intenta descargar las dependencias
#   necesarias para poder compilar posteriormente.
# - -B: ejecuta Maven en modo batch, adecuado para Docker
#   porque evita interacciones con la consola.
RUN mvn dependency:go-offline -B
# Copia el código fuente del proyecto dentro del contenedor.
#
# Se hace después de descargar las dependencias para que los
# cambios en src/ no invaliden la capa anterior de Maven.
COPY src ./src
# Compila y empaqueta la aplicación.
#
# - clean: limpia compilaciones anteriores.
# - package: compila el código y genera el archivo .jar.
# - -DskipTests: no ejecuta los tests durante el build.
# - -B: ejecuta Maven en modo batch.
#
# El .jar generado quedará normalmente en:
# /almacen-app/target/
RUN mvn clean package -DskipTests -B

# ============================================================
# ETAPA 2: RUNTIME
# ============================================================

# Utiliza una imagen más ligera que la de Maven.
#
# Esta imagen contiene únicamente el entorno necesario para
# ejecutar Java 17, no Maven ni todas las herramientas de build.
#
# Esto permite que la imagen final sea más pequeña.
FROM eclipse-temurin:17-jre
# Define /almacen-app como directorio de trabajo
# dentro del contenedor final.
WORKDIR /almacen-app
# Copia el .jar generado en la etapa anterior.
#
# --from=build:
#   indica que el archivo se toma de la etapa "build".
#
# /almacen-app/target/*.jar:
#   busca el .jar generado por Maven.
#
# almacen-app.jar:
#   es el nombre que tendrá el archivo dentro del contenedor.
COPY --from=build /almacen-app/target/*.jar almacen-app.jar
# Documenta que la aplicación utiliza el puerto 8080
# dentro del contenedor.
#
# EXPOSE no publica el puerto por sí solo.
# La publicación real se configura en docker-compose.yml.
EXPOSE 8080
# Comando que se ejecutará automáticamente cuando
# se inicie el contenedor.
#
# Ejecuta:
# java -jar almacen-app.jar
ENTRYPOINT ["java", "-jar", "almacen-app.jar"]