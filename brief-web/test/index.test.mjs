import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

test('web capture UI posts to the canonical Brief API', async () => {
	const html = await readFile(new URL('../index.html', import.meta.url), 'utf8');
	const staleProviderTerms = [
		'OPENAI_' + 'API_KEY',
		'ANTHROPIC_' + 'API_KEY',
		'Claude ' + '3 Haiku',
		'Anthro' + 'pic',
	];

	assert.match(html, /https:\/\/quickcapture-api\.daniel-ensign\.workers\.dev/);
	for (const term of staleProviderTerms) {
		assert.equal(html.includes(term), false);
	}
});
