import { Request, Response } from "express";
import { db } from "../../config/db";
import { foodEntriesTable } from "../../config/schema";
import { eq } from "drizzle-orm";
import { createEntrySchema } from "../../validations/entries/entries.validation";
import { uploadToCloudinary } from "../../services/cloudinary.service";

export class EntriesController {
  createEntry = async (req: Request, res: Response) => {
    try {
      // Validation
      const validation = createEntrySchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const {
        userId,
        menuName,
        placeName,
        category,
        price,
        dateTried,
        rating,
        notes,
      } = validation.data;

      // Check uploaded photo
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: "Photo is required",
        });
      }

      // Upload photo to Cloudinary
      const uploadResult = await uploadToCloudinary(req.file.buffer);

      const photoUrl = uploadResult.secure_url;

      // Insert entry into database
      const [insertedEntry] = await db
        .insert(foodEntriesTable)
        .values({
          userId,
          menuName,
          placeName: placeName || null,
          category,
          price: price.toFixed(2),
          dateTried,
          rating,
          photoUrl,
          notes: notes || null,
        })
        .$returningId();

      // Get created entry
      const newEntry = await db.query.foodEntriesTable.findFirst({
        where: eq(foodEntriesTable.id, insertedEntry.id),
      });

      return res.status(201).json({
        success: true,
        message: "Entry created successfully",
        data: {
          entry: newEntry,
        },
      });
    } catch (error: any) {
      console.error("Create entry error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };
}

export default new EntriesController();
