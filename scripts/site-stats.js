/* global hexo */
'use strict';

const fs = require('fs');
const path = require('path');

function stripFrontMatter(text) {
  return String(text || '').replace(/^---[\s\S]*?---\s*/, '');
}

function stripMarkdown(text) {
  return stripFrontMatter(text)
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/`[^`]*`/g, ' ')
    .replace(/\{%-?[\s\S]*?-?%\}/g, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/!\[[^\]]*]\([^)]+\)/g, ' ')
    .replace(/\[([^\]]+)]\([^)]+\)/g, ' $1 ')
    .replace(/https?:\/\/\S+/g, ' ')
    .replace(/&[a-z]+;/gi, ' ');
}

function countReadableWords(text) {
  const stripped = stripMarkdown(text);
  const cjk = stripped.match(/[\u3400-\u9fff\uf900-\ufaff]/g) || [];
  const latinWords = stripped
    .replace(/[\u3400-\u9fff\uf900-\ufaff]/g, ' ')
    .match(/[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*/g) || [];

  return cjk.length + latinWords.length;
}

function formatNumber(value) {
  return Number(value || 0).toLocaleString('zh-CN');
}

function formatWords(value) {
  const words = Number(value || 0);
  if (words >= 10000) {
    const wan = (words / 10000).toFixed(words >= 100000 ? 0 : 1).replace(/\.0$/, '');
    return `约 ${wan} 万字`;
  }
  return `约 ${formatNumber(words)} 字`;
}

function walkMarkdownFiles(dir) {
  if (!fs.existsSync(dir)) {
    return [];
  }

  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      return walkMarkdownFiles(fullPath);
    }
    return /\.(md|markdown)$/i.test(entry.name) ? [fullPath] : [];
  });
}

function getFrontMatter(text) {
  const match = String(text || '').match(/^---\s*([\s\S]*?)\s*---/);
  return match ? match[1] : '';
}

function isPublishedPost(text) {
  const frontMatter = getFrontMatter(text);
  if (/^draft:\s*true\s*$/mi.test(frontMatter)) {
    return false;
  }
  if (/^published:\s*false\s*$/mi.test(frontMatter)) {
    return false;
  }
  return true;
}

function collectPostStats(ctx) {
  const postFiles = walkMarkdownFiles(path.join(ctx.source_dir, '_posts'));
  const posts = postFiles
    .map(file => fs.readFileSync(file, 'utf8'))
    .filter(isPublishedPost);

  return {
    count: posts.length,
    words: posts.reduce((sum, content) => sum + countReadableWords(content), 0)
  };
}

function buildOverviewNode(ctx) {
  const stats = collectPostStats(ctx);

  return {
    title: '站点概览',
    content: [
      '<dl class="site-info-card site-overview-card">',
      '  <div><dt>访问量</dt><dd><span id="busuanzi_container_site_pv"><span id="busuanzi_value_site_pv">--</span> 次</span></dd></div>',
      `  <div><dt>文章数</dt><dd>${formatNumber(stats.count)} 篇</dd></div>`,
      `  <div><dt>总字数</dt><dd>${formatWords(stats.words)}</dd></div>`,
      '</dl>'
    ].join('\n')
  };
}

function injectSiteOverview(ctx) {
  const siteMemo = ctx.theme.config.widgets?.site_memo;
  if (!siteMemo || !Array.isArray(siteMemo.nodes)) {
    return;
  }

  const existingNodes = siteMemo.nodes.filter(node => {
    const title = node.title || node.header || node.date;
    return String(title) !== '站点概览';
  });

  siteMemo.nodes = [buildOverviewNode(ctx), ...existingNodes];
}

if (typeof hexo !== 'undefined') {
  hexo.extend.filter.register('before_generate', () => {
    injectSiteOverview(hexo);
  });
}

module.exports = {
  countReadableWords,
  collectPostStats,
  formatWords,
  buildOverviewNode,
  injectSiteOverview
};
