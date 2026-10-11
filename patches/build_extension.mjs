import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../..');
const blog = path.join(root, 'Blog/src/content/posts');
const out = path.join(here, 'converted');
const listFixOnly = process.argv.includes('--fix-unseparated-lists');

function listMarkdown(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const full = path.join(dir, entry.name);
    return entry.isDirectory() ? listMarkdown(full) : (entry.isFile() && entry.name.endsWith('.md') ? [full] : []);
  });
}

function escapeRE(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }
function typstString(s) { return s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n'); }

function getTitle(raw, fallback) {
  const fm = raw.match(/^---\s*\r?\n([\s\S]*?)\r?\n---\s*\r?\n?/);
  const title = fm?.[1].match(/^title:\s*["']?(.*?)["']?\s*$/m)?.[1];
  return title?.trim() || fallback;
}

function classify(rel) {
  const [top] = rel.split('/');
  const name = path.basename(rel, '.md');
  if (top === 'ALGO') return 'algo';
  if (top === 'Notes') {
    if (name === 'TODOs') return 'notes_todos';
    if (['【树论】', '【图论】', '【网络流建模】', '【一般图最大匹配】'].includes(name)) return 'notes_graph';
    if (['【哈希防卡】', '【扫描线】', '【随机化】', '【杂项】'].includes(name)) return 'notes_implementation';
    if (['【组合数学】', '【mex】'].includes(name)) return 'notes_math_misc';
    if (name === '【DP优化选型】') return 'notes_bracket_summaries';
    if (name === '【线段树用法】') return 'notes_bracket_data';
    if (['总结-DP优化选型', '总结-网络流建模'].includes(name)) return 'notes_summaries';
    if (name.startsWith('数据结构-') || ['总结-数据结构选型', '总结-线段树用法'].includes(name)) return 'notes_data_structures';
    if (name.startsWith('概率论-')) return 'notes_probability';
    if (name.startsWith('计算几何-')) return ['计算几何-三维', '计算几何-三维凸包'].includes(name) ? 'notes_geometry_3d' : 'notes_geometry_2d';
    if (name.startsWith('数学-') || name === '总结-卷积方法') return 'notes_math';
    if (name.startsWith('字符串-') || name.startsWith('总结-字符串')) return 'notes_strings';
    return 'notes_summaries';
  }
  if (top === '板子' || top === 'Draw') return 'others';
  if (top === 'Templates' || ['HDU', 'NC', 'NEU', 'CF', 'VP'].includes(top)) return 'contest';
  return 'others';
}

const noteTitles = {
  notes_graph: '图论与树论专题',
  notes_implementation: '实现技巧与杂项专题',
  notes_math_misc: '数学与计数专题',
  notes_bracket_data: '数据结构用法专题',
  notes_bracket_summaries: 'DP 优化选型专题',
  notes_probability: '概率论',
  notes_geometry_2d: '计算几何：平面专题',
  notes_geometry_3d: '计算几何：空间专题',
  notes_data_structures: '数据结构专题',
  notes_math: '数学专题集合',
  notes_strings: '字符串专题集合',
  notes_summaries: '算法选型与建模总结',
  notes_todos: 'Notes 后续整理清单',
};
const algoGroups = {
  '图论与连通性': ['2-SAT', '基环树', '欧拉回路', 'Cactus', 'E-DCC', 'SCC', 'V-DCC'],
  '图上建模与路径': ['优化建图', 'Johnson & 传递闭包'],
  '数据结构': ['K-D Tree', 'LCT'],
};

function convert(source) {
  const rel = path.relative(blog, source).split(path.sep).join('/');
  const raw = fs.readFileSync(source, 'utf8').replace(/^\uFEFF/, '');
  const kind = classify(rel);
  if (listFixOnly && !hasUnseparatedListStart(raw)) return null;
  const title = getTitle(raw, path.basename(source, '.md'));
  const body = raw.replace(/^---\s*\r?\n[\s\S]*?\r?\n---\s*\r?\n?/, '').replace(/<!--[\s\S]*?-->/g, '');
  const isCalculus = rel === 'Notes/数学-微积分.md';
  const shift = isCalculus ? 2 : kind.startsWith('notes_') || kind === 'contest' ? 3 : 2;
  const result = spawnSync('pandoc', [
    '--from=markdown+raw_html+lists_without_preceding_blankline', '--to=typst', '--wrap=none',
    `--shift-heading-level-by=${shift}`,
  ], { input: body, cwd: path.dirname(source), encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
  if (result.status !== 0) throw new Error(`Pandoc failed for ${rel}: ${result.stderr}`);
  let text = result.stdout;
  text = text.replace(/^#horizontalrule\s*$/gm, '');
  text = text.replace(/```[^\n]*\n\s*```/g, '');
  if (isCalculus) {
    text = text.replace(/^==== 微积分-终极完整版\s*$/m, '');
    text = text.replace(/^====== (\d+\. .+)$/gm, '#strong[$1]');
  }
  text = text.replace(/\$[\s\S]*?\$/g, math => math
    .replaceAll('angle.l', '⟨')
    .replaceAll('angle.r', '⟩')
    .replaceAll('times.circle', '⊙')
      .replaceAll('sect.big', 'inter.big')
      .replace(/\bunion\b(?!\.big)/g, '∪')
      .replace(/\b(?:sect|inter)\b(?!\.big)/g, '∩')
      .replace(/\bdiameter\b/g, '∅'));
  // Remove web-style heading anchors and turn local anchor links into readable labels.
  text = text.replace(/^<[^<>\n]+>\s*$/gm, '');
  text = text.replace(/#link\(<[^>]+>\)\[([^\]]*)\]/g, '$1');
  const target = path.join(out, rel.replace(/\.md$/, '.typ'));
  fs.mkdirSync(path.dirname(target), { recursive: true });
  text = text.replace(/image\("([^"\n]+)"/g, (_, old) => {
    if (/^[A-Za-z][\w+.-]*:/.test(old)) return `image("${old}"`;
    let decoded = old;
    try { decoded = decodeURIComponent(old); } catch {}
    const candidates = old.startsWith('/')
      ? [path.join(root, 'Blog/public', decoded.slice(1)), path.join(blog, decoded.slice(1))]
      : [path.resolve(path.dirname(source), decoded)];
    const asset = candidates.find(candidate => fs.existsSync(candidate));
    if (!asset) throw new Error(`Image not found for ${rel}: ${old}`);
    const assetRel = path.relative(blog, asset);
    const copy = path.join(here, 'assets', 'posts', assetRel);
    fs.mkdirSync(path.dirname(copy), { recursive: true });
    fs.copyFileSync(asset, copy);
    const relative = path.relative(path.dirname(target), copy).split(path.sep).join('/').replaceAll('"', '\\"');
    return `image("${relative}"`;
  });
  text = text.replace(/#link\("([^"\n]+)"\)\[([^\]]*)\]/g, (all, url, label) =>
    /^(?:[A-Za-z][\w+.-]*:|#)/.test(url) ? all : label);
  text = text.replace(/#cite\(<([^>]+)>(?:,\s*form:\s*"[^"]+")?\)/g, (_, key) => `#text("[${typstString(key)}]")`);
  const titleRE = new RegExp(`^={1,6}\\s+${escapeRE(title)}\\s*(?:<[^>]+>)?\\s*$`, 'm');
  text = text.replace(titleRE, '');
  const articleLevel = kind === 'algo' ? 3 : kind === 'others' ? 2 : kind.startsWith('notes_') ? 4 : 3;
  const sourceNote = `#text(size: 0.72em, fill: gray)[来源：\`Blog/src/content/posts/${rel}\`]`;
  const startPage = isCalculus ? '#pagebreak(weak: true)\n' : '';
  fs.writeFileSync(target, `${startPage}${'='.repeat(articleLevel)} #text("${typstString(title)}")\n${sourceNote}\n\n${text.trimStart()}\n`, 'utf8');
  return { rel, kind, title, include: path.relative(here, target).split(path.sep).join('/') };
}

function hasUnseparatedListStart(raw) {
  const body = raw.replace(/^---\s*\r?\n[\s\S]*?\r?\n---\s*\r?\n?/, '').replace(/<!--[\s\S]*?-->/g, '');
  const lines = body.split(/\r?\n/);
  return lines.some((line, i) => {
    if (i === 0 || !/^ {0,3}(?:[-+*]|\d+[.)])\s+\S/.test(line) || !lines[i - 1].trim()) return false;
    return !/^\s*(?:[-+*]|\d+[.)])\s+\S/.test(lines[i - 1]);
  });
}

function writeIndex(name, title, items, groupByTop = false) {
  const lines = [`= ${title}`, ''];
  let last = '';
  for (const item of items) {
    const top = item.rel.split('/')[0];
    if (groupByTop && top !== last) {
      last = top;
      lines.push(`== ${top}`, '');
    }
    lines.push(`#include "${item.include}"`, '');
  }
  fs.writeFileSync(path.join(here, name), lines.join('\n'), 'utf8');
}

const articles = listMarkdown(blog).sort((a, b) => a.localeCompare(b, 'zh-CN')).map(convert).filter(Boolean);
if (!listFixOnly) {
writeIndex('01_contest.typ', 'CONTEST', articles.filter(x => x.kind === 'contest'), true);
const algoArticles = articles.filter(x => x.kind === 'algo');
const algoIndex = ['= ALGO', ''];
for (const [group, names] of Object.entries(algoGroups)) {
  algoIndex.push(`== ${group}`, '');
  for (const name of names) {
    const article = algoArticles.find(x => path.basename(x.rel, '.md') === name);
    if (article) algoIndex.push(`#include "${article.include}"`, '');
  }
}
fs.writeFileSync(path.join(here, '02_algo.typ'), algoIndex.join('\n'), 'utf8');

const noteIndex = ['= Notes', '', '== 标签专题', ''];
const bracketKeys = ['notes_graph', 'notes_implementation', 'notes_math_misc', 'notes_bracket_data', 'notes_bracket_summaries'];
const collectionKeys = ['notes_probability', 'notes_geometry_2d', 'notes_geometry_3d', 'notes_data_structures', 'notes_math', 'notes_strings', 'notes_summaries', 'notes_todos'];
const noteFiles = new Set();
function addNoteGroup(key) {
  const entries = articles.filter(x => x.kind === key);
  if (!entries.length || noteFiles.has(key)) return;
  noteFiles.add(key);
  const relative = `notes/${key.replace('notes_', '')}.typ`;
  const lines = [`=== ${noteTitles[key]}`, ''];
  for (const entry of entries) lines.push(`#include "../${entry.include}"`, '');
  fs.mkdirSync(path.dirname(path.join(here, relative)), { recursive: true });
  fs.writeFileSync(path.join(here, relative), lines.join('\n'), 'utf8');
  noteIndex.push(`#include "${relative}"`, '');
}
for (const key of bracketKeys) addNoteGroup(key);
noteIndex.push('== 主题-子主题专题集合', '');
for (const key of collectionKeys) addNoteGroup(key);
if (articles.some(x => x.kind === 'notes_todos')) addNoteGroup('notes_todos');
fs.writeFileSync(path.join(here, '03_notes.typ'), noteIndex.join('\n'), 'utf8');
writeIndex('04_others.typ', 'Others', articles.filter(x => x.kind === 'others'));

fs.writeFileSync(path.join(root, 'mainPatchContest.typ'), '#import "patches/notebook_patch.typ": *\n\n#notebook(title: "ACMT 扩展卷：CONTEST", outline-depth: 5, compact: false)[\n  #include "patches/01_contest.typ"\n]\n', 'utf8');
fs.writeFileSync(path.join(root, 'mainPatchAlgo.typ'), '#import "patches/notebook_patch.typ": *\n\n#notebook(title: "ACMT 扩展卷：ALGO", outline-depth: 4, compact: false)[\n  #include "patches/02_algo.typ"\n]\n', 'utf8');
fs.writeFileSync(path.join(root, 'mainPatchNotes.typ'), '#import "patches/notebook_patch.typ": *\n\n#notebook(title: "ACMT 扩展卷：Notes / Others", outline-depth: 4, compact: false)[\n  #include "patches/03_notes.typ"\n  #include "patches/04_others.typ"\n]\n', 'utf8');
}
console.log(listFixOnly
  ? `Reconverted ${articles.length} articles containing list markers without a blank line.`
  : `Converted ${articles.length} posts into Typst source files under patches/converted.`);
