/**
 * Generate a URL-safe slug from a string.
 * Handles Unicode, removes special characters, lowercases.
 */
const slugify = (text) => {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')       // spaces → hyphens
    .replace(/[^\w\-]+/g, '')   // remove non-word chars (except hyphens)
    .replace(/\-\-+/g, '-')    // collapse multiple hyphens
    .replace(/^-+/, '')         // trim leading hyphens
    .replace(/-+$/, '');        // trim trailing hyphens
};

/**
 * Generate a unique slug by checking the database for collisions.
 * @param {string} text - The text to slugify
 * @param {Model} Model - Mongoose model to check against
 * @param {string|null} excludeId - Exclude this document ID from collision check (for updates)
 */
const generateUniqueSlug = async (text, Model, excludeId = null) => {
  let slug = slugify(text);
  if (!slug) slug = 'item';

  let candidate = slug;
  let counter = 0;

  while (true) {
    const query = { slug: candidate };
    if (excludeId) query._id = { $ne: excludeId };

    const existing = await Model.findOne(query).select('_id').lean();
    if (!existing) return candidate;

    counter++;
    candidate = `${slug}-${counter}`;
  }
};

module.exports = { slugify, generateUniqueSlug };
