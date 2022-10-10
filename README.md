# Labradorite Notebook (work in progress)

> Labradorite rightfully belongs to the group of wisdom crystals, because it promotes a free flow of mental energy as it awakens intuition and allows us to get mentally unstuck.  
> \- every esoteric out there

<div align="center">
  <p>
    <img src="https://github.com/simonneutert/labradorite-notebook/blob/development/public/labradorite.jpg?raw=true" alt="Labradorite dreamed by openai's Dall-E2: A brown labrador shooting a lazer from a blue crystal on its forehead, digital art">
  </p>
</div>

---

## Rationale

Most Notetaking apps do either too much (Notion), too less (Apple Notes) or locked me in (Evernote).

I wanted something that does **just-enough**™. Let me try and wrap it up in a few bullets:

- ownership of the notes  
  markdown, yaml, attachments all in one place in directories
- hide the clutter  
  I don't want to see all the old stuff I may not need anymore
- a search that shows me snips in the notes  
  not just the notes in a sidebar
- a very simple tagging support
- basic file uploads (UX like github)  
  keeping the originals side by side with notes

I like to keep things simple, so I once again fell for [Roda](https://roda.jeremyevans.net) as the Web Layer. [Tantiny](https://github.com/baygeldin/tantiny) is the kicker for this project. I was curious if I could come up with something useful for this, not having to deal with a complicated setup or Postgres as a requirement.

## Architecture

Little experiment on how it rolls:

- all GET get HTML
- all POST sends FORMS/JSON gets JSON back
- all links/navigation are plain HTML `a` tags 🤯

## Folder Structure

- `lib`: Library Code / Business Logic
- `views`: ERB Views
- `memos`: the Memos/Notes in subdirectories `YYYY/MM/DD/random-string`
- `public`: css/js/media
- `.tantiny`: the local index data created by the [tantiny](https://github.com/baygeldin/tantiny) gem

## Major Dependencies

- Roda
- Tantiny
- RedCarpet

## Docker

https://stackoverflow.com/a/56844765

UID=${UID} GID=${GID} docker-compose up

## Follow-up: Inspiration, Knowledge

#### Rails

https://stevepolito.design/blog/search-across-multiple-models-in-rails/

Gist: a searchable table is to be added and kept updated using commit_hooks
