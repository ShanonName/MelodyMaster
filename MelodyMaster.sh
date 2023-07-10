function handle_sigint() {
    echo -e "${RED}Se recibió la señal SIGINT (Ctrl+C). Saliendo...${RESET}"
    if [ ! -e "$path"*.mp3 ] && [ -d "$path" ]; then
        rm -rf "$path"
    fi
    exit 0
}

checkVersion() {
    ver=$(curl -s https://raw.githubusercontent.com/ShanonName/MelodyMaster/main/version.txt)
    if [[ "$ver" == "$version" ]]; then
        cv="$GREEN"
        return 0
    fi
    echo -e "${RED}Programa desactualizado, porfavor actualizar${RESET}"
    cv="$RED"
}

check_depends() {
    depends=("jq" "spotdl" "curl")
    for d in "${depends[@]}"; do
        local c=$(command -v "$d")
        if [[ "$c" == "" ]]; then
            echo -e "${RED} [!] Error '${d}' no encontrado, por favor descargar.${RESET}"
            local exit=true
        fi
    done
    
    if [[ $exit == true ]]; then
            exit 0
        fi
}

main() {
    if [[ ${#querys[@]} == 0 ]]; then
        echo -e "${RED}No se han dado datos a buscar${RESET}"
        print_usage
    fi
    echo -e "${BLUE}[${RED}!${BLUE}] ${GREEN} Scaneando ${#querys[@]} busquedas ${RESET}"

    # Busca todas las canciones y las deja en el directorio especificado
    for query in "${querys[@]}"
    do
        cd $spath
        get_spotify_info "$query"

        if [[ "$link" == "null" ]]; then
            echo -e "${RED}[!] Error link invalido ${RESET}"
            continue
        fi

        # Define el directorio donde ira la musica y lo crea si no existe
        path="${spath}/albums/${artist}/${album}"
        if [[ "$type" == "playlist" ]]; then
            path="${spath}/playlists/${name}"
        fi
        if [ ! -d "${path}" ]; then
            mkdir -p "$path/"
        fi

        # Descarga la cancion/album/playlist si no esta el --preview-only
        if [[ ! $arg_JP ]]; then    
            cd "$path"; $command "$link"
        fi
        
        # Descargamos el banner del album/cancion/playlist yk
        download_banner "$imgurl" "${path}/${album}.png"
    done
}

print_usage() {
    filename=$(basename "$0")
    echo "usage: ./${filename} (options) [links, querys]*"
    echo "options:"
    echo "  --preview-only  Descarga solo la portada de las canciones/albums/playlists."
    echo "  --help, -h      Muestra este menu y sale."
    echo "  --version, -v   Imprime la version del programa y sale."
    echo ""
    echo "Links, Querys     Datos a buscar para luego descargar"
    exit 0
}

print_logo() {
    if [[ $arg_quiet == true ]]; then
        return 0
    fi

    echo -e "\033[1m\033[34m"
    echo "--------------------------------------"
    echo ""
    echo "   ███╗   ███╗       ███╗   ███╗"
    echo "   ████╗ ████║       ████╗ ████║"
    echo "   ██╔████╔██║       ██╔████╔██║"
    echo "   ██║╚██╔╝██║       ██║╚██╔╝██║"
    echo "   ██║ ╚═╝ ██║elody  ██║ ╚═╝ ██║aster"
    echo "   ╚═╝     ╚═╝       ╚═╝     ╚═╝"
    echo -e "${RED}Para ayudarte en algo que no necesitas. ${RESET}"
    echo ""
    echo -e "\033[1m\033[34m--------------------------------------"
    echo -e "${BLUE}By: \033[33m@shanonName ${RESET}"
    echo -e "${BLUE}Version: ${cv}${version} ${RESET}"
    echo -e "\033[1m\033[34m--------------------------------------"
    echo -e "\033[0m"
}

get_token() {
    date=$(date +%s)
    if [[ $token ]]; then
        if (( $((date-3600)) < $((expiration+500)) )); then
            return 0
        fi
    fi
    echo -e "${RED}No se ha encontrado un token valido en ${cPath}..., ${GREEN}consiguiendo uno nuevo...${RESET}"
    local g=$(curl -s -X POST "https://accounts.spotify.com/api/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=${clientID}&client_secret=${clientSecret}")
    token=$(jq -r '.access_token' <<< "$g")
    local exp=$(jq -r '.expires_in' <<< "$g")
    expiration=$((date+exp))

    if [[ $(cat "$cPath" | grep -o "token=") == "token=" ]]; then
        sed -i "s/^token=.*$/token=${token}/" "$cPath"
        sed -i "s/^expiration=.*$/expiration=${expiration}/" "$cPath"
    else
        echo "" >> "$cPath"
        echo "# No modificar los siguientes valores al menos que sepas lo que haces" >> "$cPath"
        echo "token=${token}" >> "$cPath"
        echo "expiration=${expiration}" >> "$cPath"
    fi
    exit 0
}

getEnv() {
    cPath="config.env"
    if [[ ! -e "$cPath" ]]; then
        echo -e "${YELLOW}[${RED}!${YELLOW}] ${RED}No se ha encontrado el archivo de configuracion, creandolo... ${RESET}"
        read -p $'\033[0;32mCLIENT ID:\033[0m ' clientID
        echo -e "${YELLOW} 'CLIENT ID' establecido a '${clientID}' ${RESET}"
        read -s -p $'\033[0;32mCLIENT SECRET:\033[0m ' clientSecret
        echo -e "${YELLOW} 'CLIENT Secret' establecido... ${RESET}"
        command="spotdl --preload"
        spath="${HOME}/Music"
        limit=5

        echo "clientID=${clientID}" > "$cPath"
        echo "clientSecret=${clientSecret}" >> "$cPath"
        echo "limit=${limit}" >> "$cPath"
        echo "command='${command}'" >> "$cPath"
        echo "spath=${spath}" >> "$cPath"

        echo -e "${BLUE}[${GREEN}!${BLUE}] ${GREEN}Configuracion guardada en '${cPath}' ${RESET}"
    fi

    source "./$cPath"
}

get_spotify_info() {
    local url="$1"
    local check=$(echo "$url" | grep -o "https://open.spotify.com/")
    if [[ ! "$check" == "https://open.spotify.com/" ]]; then
        echo -e "${BLUE}[${RED}!${BLUE}] $YELLOW Buscando cancion por ${url} ${RESET}"	
        
        # Parseamos query ej: "The Normal Album" -> "The%20Normal%20Album"
        url=${url// /%20}
        
        # Obtenemos canciones/albums con ese nombre
        # Para la query puedes usar los filtros que entrega spotify en su api
        # Ver en la pagina de la api: 'https://developer.spotify.com/documentation/web-api/reference/search'

        local response=$(curl -s "https://api.spotify.com/v1/search?q=${url}&type=album%2Ctrack&limit=${limit}" -H "Authorization: Bearer $token")
        
        # Imprimimos todas las opciones en pantalla para luego que el usuario elija
        for j in 0 1; do
            pattern="albums"   
            if ((j == 1)); then
                pattern="tracks"
            fi
            echo -e "${RED}${pattern}${RESET}"

            for i in $(seq 0 $((limit - 1))); do
                local pette=".${pattern}.items[${i}]"
                name=$(jq -r "${pette}.name" <<< "$response")
                artist=$(jq -r "${pette}.artists[0].name" <<< "$response")
                n=$((i + 1 + (j * limit)))
                echo -e "${BLUE}[${YELLOW}${n}${BLUE}] ${GREEN} ${name} - ${artist} ${RESET}"
            done
        done
                

        read -p $'\033[0;32m> \033[0m' option
        
        local typed=".albums"
        local item=$((option-1))
        if (( $((option-5)) > 0 )); then
            typed=".tracks"
            item=$((item-5))
        fi
        local pattern="${typed}.items[${item}]"
    elif [[ "$check" == "https://open.spotify.com/" ]]; then
        echo -e "${BLUE}[${RED}!${BLUE}] $YELLOW Obteniendo info desde el link ${url} ${RESET}"
    
        # Extraer el ID de la pista o el álbum del enlace de Spotify
        id=$(echo "$url" | awk -F'/' '{print $(NF)}')
        type=$(echo "$url" | awk -F '/' '{print $(NF-1)}')    

        # Realizar la solicitud a la API de Spotify para obtener la información del artista y el álbum
        local response=$(curl -s "https://api.spotify.com/v1/${type}s/${id}" -H "Authorization: Bearer $token")
        local pattern=""
    else
        echo -e "${RED} [!] Link invalido${RESET}"
        return 0
    fi

    # Extraer el nombre del artista y el álbum de la respuesta JSON
    artist=$(jq -r "${pattern}.artists[0].name" <<< "$response")
    name=$(jq -r "${pattern}.name" <<< "$response")
    id=$(jq -r "${pattern}.id" <<< "$response")
    link=$(jq -r "${pattern}.external_urls.spotify" <<< "$response")
    imgurl=$(jq -r "${pattern}.images[0].url" <<< "$response")
    album=$(jq -r "${pattern}.album.name" <<< "$reponse")

    if [[ "$album" == "null" ]]; then
        album="$name"
    fi
}

download_banner() {
    local url=$1
    local pathimg=$2

    if [[ "$url" == "null" ]]; then
        echo -e "${RED}[!] Error url invalido ${RESET}"
    	return 0
    fi

    if [ -e "$pathimg" ]; then
        echo -e "${RED}[!] Error la imagen ${YELLOW}"${pathimg}"${RED} ya existe ${RESET}"
	    return 0
    fi

    curl -o "$pathimg" -s "$url"
    echo -e "${BLUE}[${RED}!${BLUE}] ${GREEN} Portada de la cancion descargada desde ${url} y guardada en ${pathimg}${RESET}"
}

# Catch ctrl+C and exit
trap handle_sigint SIGINT

# Definiendo colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

version=1.0
checkVersion

# Detectando argumentos
querys=()
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            # Muestra ayuda
            print_logo
            print_usage
            ;;
        -q | --quiet)
            # No banner
            arg_quiet=true
            ;;
        --preview-only)
            # Solo Fotos
            arg_JP=true
            ;;
        -v | --version)
            # Muestra la version
            print_logo
            echo "Version $version"
            exit 0
            ;;
        -*)
            # Invalido
            print_logo
            echo -e "${RED}Argumento invalido...${RESET}"
            print_usage
            ;;
        *)
            # Links
            querys+=("$arg")
            ;;
    esac
done

print_logo
check_depends

# Obtenemos la informacion para iniciar el programa
getEnv
get_token

main