import re

with open("src/lib/api.js", "r", encoding="utf-8") as f:
    content = f.read()

old_fetch = """  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });"""

new_fetch = """  let response;
  try {
    response = await fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers,
    });
  } catch (error) {
    console.error(`Fetch failed for URL: ${API_BASE}${endpoint}`, error);
    throw error;
  }"""

content = content.replace(old_fetch, new_fetch)

with open("src/lib/api.js", "w", encoding="utf-8") as f:
    f.write(content)
