import { z } from "zod";

export const createEntrySchema = z.object({
  menuName: z.string().min(1, "Menu name is required"),
  placeName: z.string().optional(),
  category: z.enum(["Food", "Drink"]),
  price: z.coerce.number().min(0, "Price cannot be negative"),
  dateTried: z.string().min(1, "Date is required"),
  rating: z.coerce.number().int().min(1).max(5),
  notes: z.string().optional(),

  isPublic: z
    .union([
      z.boolean(),
      z.enum(["true", "false"]).transform((value) => value === "true"),
    ])
    .optional()
    .default(false),
});

export const updateEntrySchema = createEntrySchema.partial();
