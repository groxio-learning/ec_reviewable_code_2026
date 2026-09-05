# Wordlex word corpus

Wordlex vendors the two canonical lists extracted from the original Wordle web application:

- `answers.txt`: 2,315 possible answers, alphabetized
- `allowed_guesses.txt`: 10,657 supplemental accepted guesses, excluding answers

Together they contain 12,972 accepted five-letter words. The files retain the lowercase, one-word-per-line format of their sources; Wordlex normalizes words to uppercase when constructing the domain dictionary.

## Provenance

Retrieved on 2026-09-04 from GitHub gists maintained by Christopher Freshman:

- Answers: <https://gist.github.com/cfreshman/a03ef2cba789d8cf00c08f767e0fad7b>
  - Raw revision: `50838083dca5359b3cacf1ab677059b40c0e025e`
  - SHA-256: `5209b35f823f8b80f0404f863bd80df06d6a966c6eb1016d69f38badc6eed5d0`
- Supplemental guesses: <https://gist.github.com/cfreshman/cdcdf777450c5b5301e439061d29694c>
  - Raw revision: `cc443a0688b07ab5947afd3975160975547fc513`
  - SHA-256: `99be2e38dadf3e26952af7cb4d963f65b632d5de91aa99e5ce308e4dc9617b65`

The source gists do not state a separate license. The lists are reproduced here as factual game data for this educational project. Review redistribution requirements before using them in another context.

## Updating

Updates must be deliberate rather than following a moving URL:

1. Download immutable raw revisions into the two files.
2. Verify that every line is a unique, lowercase, five-letter ASCII word.
3. Verify counts of 2,315 answers, 10,657 supplemental guesses, zero overlap, and a 12,972-word union.
4. Update revision IDs and checksums above.
5. Run `mix test test/wordlex/dictionary_test.exs`.
