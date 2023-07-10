<div align="center">

# Melody Master

![img](http://raw.github.com/ShanonName/MelodyMaster/MelodyMaster.png)

**Melody Master** Descarga y organiza canciones de la manera mas eficiente posible.

**Creado por**: [@ShanonName](https://github.com/ShanonName/)

> ***Melody Master***: Es mejor perder 2 dias creando un programa que lo haga automatico que hacerlo manual.

----
</div>

## Descripcion

Melody Master es una herramienta de línea de comandos diseñada para descargar y organizar automáticamente canciones desde Spotify. También permite buscar canciones, álbumes o listas de reproducción y descargar sus imágenes asociadas.

## Requisitos previos

Antes de utilizar Melody Master, asegúrate de tener instalados los siguientes elementos:

- [jq](https://stedolan.github.io/jq/): Una herramienta de procesamiento de JSON utilizada para extraer información de las respuestas de la API de Spotify.
- [spotdl](https://github.com/spotDL/spotify-downloader): Una herramienta de línea de comandos utilizada para descargar canciones de Spotify.

## Instalación

1. Clona este repositorio en tu máquina local:

```bash
git clone https://github.com/ShanonName/MelodyMaster.git
```

2. Accede al directorio del proyecto:

```bash
cd "MelodyMaster"
```

3. Ejecuta el script `MelodyMaster.sh` para comenzar a utilizar Melody Master:

```bash
./MelodyMaster.sh [opciones] [enlaces o consultas]
```

### IMPORTANTE!

En la primera ejecucion se pedira un `clientID` y un `clientSecret`, estos valores
se pueden conseguir creando una aplicacion en `https://developer.spotify.com/dashboard`
estos valores son necesarios para poder hacer cualquier peticion a la api.

## Uso

Melody Master admite las siguientes opciones:

- `--preview-only`: Descarga solo la imagen de la canción, álbum o lista de reproducción.
- `--quiet` (`-q`): No imprime el banner del programa.
- `--help` (`-h`): Muestra el menú de ayuda con información sobre cómo utilizar la herramienta.
- `--version` (`-v`): Muestra la versión actual de Melody Master.

Los enlaces o consultas son los datos que se utilizarán para buscar y descargar canciones. Puedes proporcionar uno o varios enlaces o consultas separados por espacios.

> El link tiene que ser de spotify!

## Configuracion

Melody Master creara un archivo `config.env` en el directorio de trabajo con algunos valores por defecto
y las creedenciales de la aplicacion de spotify otorgadas.

En estas opciones modificables podemos ver lo siguiente

- `clientID`: La id de la app de spotify.
- `clientSecret`: La Secret Key de la app.
- `limit`: La cantidad de canciones que se devolveran cuando se haga una busqueda con la api.
- `command`: El comando de 'spotdl' que se ejecutara (aqui puedes poner todos los argumentos para el comando).
- `spath`: El directorio donde se guardaran todos los archivos.

## Ejemplos de uso

A continuación se presentan algunos ejemplos de uso de Melody Master:

- Descargar canciones de Spotify utilizando enlaces:

```bash
./MelodyMaster.sh https://open.spotify.com/track/xxxxxxxxxxxx https://open.spotify.com/track/yyyyyyyyyyyy
```

- Buscar y descargar canciones por consultas:

```bash
./MelodyMaster.sh "nombre de la canción" "nombre del álbum"
```

- Descargar solo las imágenes de los álbumes:

```bash
./MelodyMaster.sh --preview-only https://open.spotify.com/album/zzzzzzzzzzzz https://open.spotify.com/album/wwwwwwwwwwww
```

## Contribuir

Si deseas contribuir a Melody Master, siéntete libre de hacer un fork del repositorio, realizar tus cambios y enviar un pull request. También puedes informar sobre cualquier problema o sugerencia utilizando la sección de "Issues" en GitHub.

----

> **Gracias por usar Melody Master :D**