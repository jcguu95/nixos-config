// ==UserScript==
// @name           YT: not interested in one click
// @description    Hover a thumbnail to see icons at the right: "Not interested" and "Don't recommend channel"
// @version        1.0.5
//
// @match          https://www.youtube.com/*
//
// @noframes
// @grant          none
//
// @author         wOxxOm
// @namespace      wOxxOm.scripts
// @license        MIT License
// ==/UserScript==

const ME = 'yt-one-click-dismiss';
const THUMB_TAG = 'ytd-thumbnail';
const COMMANDS = {
  NOT_INTERESTED: {block: 'video', text: 'Not interested'},
  REMOVE: {block: 'channel', text: "Don't recommend channel"},
  DELETE: {block: 'unwatch', text: "Remove from 'Watch later'"},
};
let STYLE;

const isThumb = el => el.localName === THUMB_TAG;

addEventListener('mouseover', onHover);
addEventListener('click', onClick, true);

function onHover(e) {
  const thumb = e.composedPath().find(isThumb);
  if (thumb && !thumb.getElementsByClassName(ME)[0]) {
    for (const type of getMenuItems(thumb))
      if (COMMANDS[type])
        thumb.appendChild(COMMANDS[type].element);
  }
}

async function onClick(e) {
  const {target} = e;
  const {block} = target.classList.contains(ME) && target.dataset;
  if (!block)
    return;
  e.stopPropagation();
  e.preventDefault();
  try {
    const index = STYLE.sheet.insertRule('ytd-menu-popup-renderer { display: none !important }');
    for (let more, el = target; el; el = el.parentElement) {
      if ((more = el.querySelector('.dropdown-trigger'))) {
        await 0;
        more.dispatchEvent(new Event('tap'));
        await 0;
        break;
      }
    }
    for (const el of document.querySelector('ytd-menu-popup-renderer [role="listbox"]').children) {
      if (block === (COMMANDS[el.data.icon.iconType] || {}).block) {
        el.click();
        await new Promise(setTimeout);
        break;
      }
    }
    document.body.click()
    STYLE.sheet.deleteRule(index);
  } catch (e) {}
}

function *getMenuItems(thumb) {
  try {
    for (const {menuServiceItemRenderer: {icon, text}} of thumb.data.menu.menuRenderer.items) {
      const type = icon.iconType;
      const data = COMMANDS[type];
      if (data) {
        if (!data.element) {
          const el = data.element = document.createElement('div');
          el.className = ME;
          el.dataset.block = data.block;
          el.title = text.runs.map(r => r.text).join('') || data.text;
        }
        yield type;
      }
    }
    if (!STYLE) initStyle();
  } catch (e) {}
}

function initStyle() {
  STYLE = document.createElement('style');
  STYLE.textContent = /*language=CSS*/ `
${THUMB_TAG}:hover .${ME} {
  display: block;
}
.${ME} {
  display: none;
  position: absolute;
  width: 16px;
  height: 16px;
  border-radius: 100%;
  border: 2px solid #fff;
  right: 8px;
  background: #0006;
  box-shadow: .5px .5px 7px #000;
  cursor: pointer;
  opacity: .75;
  z-index: 100;
}
.${ME}:hover {
  opacity: 1;
}
.${ME}:active {
  color: yellow;
}
.${ME}[data-block] {
  top: 70px;
}
.${ME}[data-block="channel"] {
  top: 100px;
}
.ytd-playlist-video-renderer .${ME}[data-block="unwatch"] {
  top: 15px;
}
.${ME}::after {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  height: 0;
  margin: auto;
  border: none;
  border-bottom: 2px solid #fff;
}
.${ME}[data-block="video"]::after {
  transform: rotate(45deg);
}
.${ME}[data-block="channel"]::after {
  margin: auto 3px;
}
`.replace(/;/g, '!important;');
  document.head.appendChild(STYLE);
}
