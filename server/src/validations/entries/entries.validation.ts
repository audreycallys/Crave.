import { z } from "zod";

export const createEntrySchema = z.object({
  userId: z.coerce.number().int().positive(),
  menuName: z.string().min(1, "Menu name is required"),
  placeName: z.string().optional(),
  category: z.enum(["Food", "Drink"]),
  price: z.coerce.number().min(0, "Price cannot be negative"),
  dateTried: z.string().min(1, "Date is required"),
  rating: z.coerce.number().int().min(1).max(5),
  notes: z.string().optional(),
});

export const updateEntrySchema = createEntrySchema
  .omit({
    userId: true,
  })
  .partial();