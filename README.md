# HammerAlert

Addon de EKO para **WoW Forever** que avisa cuando **Hammer of Wrath** está disponible para el objetivo seleccionado en combate.

## Qué incluye la versión 2.7

- Detecta automáticamente Hammer of Wrath en las ranuras 1 a 120 de las barras de acción y toma el icono de la habilidad.
- Muestra el aviso cuando estás en combate, tienes un objetivo vivo y atacable, y el cliente indica que la acción está disponible.
- Muestra un halo dorado pulsante con dos destellos que recorren el borde. El sonido opcional se reproduce cuando la habilidad pasa a estar disponible.
- Permite ajustar el tamaño y la posición del aviso. El botón de ajustes se puede arrastrar por el borde del minimapa. El addon guarda ambas posiciones, el tamaño y la preferencia de sonido.

## Instalación

1. Descarga el código de la [versión v2.7](https://github.com/pablodiazm88-svg/HammerAlert/tree/v2.7) y extrae el ZIP.
2. Coloca `HammerAlert.lua` y `HammerAlert.toc` dentro de `_forever_\Interface\AddOns\HammerAlert` en la carpeta del juego.
3. Abre WoW Forever, habilita **HammerAlert** en la lista de addons y coloca **Hammer of Wrath** directamente en una barra de acción.

## Ajustes y prueba

Haz clic en el martillo del minimapa para abrir los ajustes. Desde el panel puedes cambiar el tamaño, activar o probar el sonido y mostrar el aviso para moverlo. Con el aviso de prueba visible, mantén **Shift** y arrástralo. Para recolocar el botón del minimapa, arrástralo con el botón izquierdo por el borde.

Tras actualizar una instalación existente, ejecuta `/reload` y luego `/hammer test` para ver el icono y su animación. Repite `/hammer test` para volver al aviso automático y probarlo en combate.

| Comando | Acción |
| --- | --- |
| `/hammer` | Muestra la ayuda. |
| `/hammer config` | Abre o cierra los ajustes. |
| `/hammer test` | Activa o desactiva el modo de prueba. |
| `/hammer size 80` | Cambia el tamaño del icono. Acepta valores de 30 a 200. |
| `/hammer sound on` | Activa el sonido. |
| `/hammer sound off` | Desactiva el sonido. |
| `/hammer sound test` | Reproduce el sonido si está activado. |
| `/hammer info` | Muestra el tamaño, la posición del aviso y el estado del sonido. |
