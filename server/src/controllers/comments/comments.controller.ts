import { Response } from "express";
import { and, desc, eq, or } from "drizzle-orm";

import { db } from "../../config/db";
import {
  commentsTable,
  foodEntriesTable,
  usersTable,
} from "../../config/schema";
import { AuthRequest } from "../../middleware/auth.middleware";
import {
  createCommentSchema,
  updateCommentSchema,
} from "../../validations/comments/comments.validation";

class CommentsController {
  getComments = async (req: AuthRequest, res: Response) => {
    try {
      const entryId = Number(req.params.id);
      const userId = req.user!.id;

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      const [entry] = await db
        .select()
        .from(foodEntriesTable)
        .where(
          and(
            eq(foodEntriesTable.id, entryId),
            or(
              eq(foodEntriesTable.isPublic, true),
              eq(foodEntriesTable.userId, userId),
            ),
          ),
        )
        .limit(1);

      if (!entry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      const comments = await db
        .select({
          id: commentsTable.id,
          entryId: commentsTable.entryId,
          userId: commentsTable.userId,
          content: commentsTable.content,
          createdAt: commentsTable.createdAt,
          updatedAt: commentsTable.updatedAt,
          user: {
            id: usersTable.id,
            name: usersTable.name,
            profilePhotoUrl: usersTable.profilePhotoUrl,
          },
        })
        .from(commentsTable)
        .innerJoin(usersTable, eq(commentsTable.userId, usersTable.id))
        .where(eq(commentsTable.entryId, entryId))
        .orderBy(desc(commentsTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "Comments retrieved successfully",
        data: { comments },
      });
    } catch (error) {
      console.error("Get comments error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve comments",
      });
    }
  };

  createComment = async (req: AuthRequest, res: Response) => {
    try {
      const entryId = Number(req.params.id);
      const userId = req.user!.id;

      if (!Number.isInteger(entryId) || entryId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid entry ID",
        });
      }

      const validation = createCommentSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      const [entry] = await db
        .select()
        .from(foodEntriesTable)
        .where(
          and(
            eq(foodEntriesTable.id, entryId),
            or(
              eq(foodEntriesTable.isPublic, true),
              eq(foodEntriesTable.userId, userId),
            ),
          ),
        )
        .limit(1);

      if (!entry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      const [insertedComment] = await db
        .insert(commentsTable)
        .values({
          entryId,
          userId,
          content: validation.data.content,
        })
        .$returningId();

      const [comment] = await db
        .select({
          id: commentsTable.id,
          entryId: commentsTable.entryId,
          userId: commentsTable.userId,
          content: commentsTable.content,
          createdAt: commentsTable.createdAt,
          updatedAt: commentsTable.updatedAt,
          user: {
            id: usersTable.id,
            name: usersTable.name,
            profilePhotoUrl: usersTable.profilePhotoUrl,
          },
        })
        .from(commentsTable)
        .innerJoin(usersTable, eq(commentsTable.userId, usersTable.id))
        .where(eq(commentsTable.id, insertedComment.id))
        .limit(1);

      return res.status(201).json({
        success: true,
        message: "Comment created successfully",
        data: { comment },
      });
    } catch (error) {
      console.error("Create comment error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to create comment",
      });
    }
  };

  updateComment = async (req: AuthRequest, res: Response) => {
    try {
      const commentId = Number(req.params.id);
      const userId = req.user!.id;

      if (!Number.isInteger(commentId) || commentId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid comment ID",
        });
      }

      const validation = updateCommentSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          errors: validation.error.flatten().fieldErrors,
        });
      }

      if (!validation.data.content) {
        return res.status(400).json({
          success: false,
          message: "Comment content is required",
        });
      }

      const [comment] = await db
        .select()
        .from(commentsTable)
        .where(eq(commentsTable.id, commentId))
        .limit(1);

      if (!comment) {
        return res.status(404).json({
          success: false,
          message: "Comment not found",
        });
      }

      if (comment.userId !== userId) {
        return res.status(403).json({
          success: false,
          message: "You are not allowed to edit this comment",
        });
      }

      const [entry] = await db
        .select()
        .from(foodEntriesTable)
        .where(
          and(
            eq(foodEntriesTable.id, comment.entryId),
            or(
              eq(foodEntriesTable.isPublic, true),
              eq(foodEntriesTable.userId, userId),
            ),
          ),
        )
        .limit(1);

      if (!entry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      await db
        .update(commentsTable)
        .set({ content: validation.data.content })
        .where(eq(commentsTable.id, commentId));

      const [updatedComment] = await db
        .select()
        .from(commentsTable)
        .where(eq(commentsTable.id, commentId))
        .limit(1);

      return res.status(200).json({
        success: true,
        message: "Comment updated successfully",
        data: { comment: updatedComment },
      });
    } catch (error) {
      console.error("Update comment error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update comment",
      });
    }
  };

  deleteComment = async (req: AuthRequest, res: Response) => {
    try {
      const commentId = Number(req.params.id);
      const userId = req.user!.id;

      if (!Number.isInteger(commentId) || commentId <= 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid comment ID",
        });
      }

      const [comment] = await db
        .select()
        .from(commentsTable)
        .where(eq(commentsTable.id, commentId))
        .limit(1);

      if (!comment) {
        return res.status(404).json({
          success: false,
          message: "Comment not found",
        });
      }

      const [entry] = await db
        .select()
        .from(foodEntriesTable)
        .where(eq(foodEntriesTable.id, comment.entryId))
        .limit(1);

      if (!entry) {
        return res.status(404).json({
          success: false,
          message: "Entry not found",
        });
      }

      const isCommentOwner = comment.userId === userId;
      const isEntryOwner = entry.userId === userId;

      if (!isCommentOwner && !isEntryOwner) {
        return res.status(403).json({
          success: false,
          message: "You are not allowed to delete this comment",
        });
      }

      await db.delete(commentsTable).where(eq(commentsTable.id, commentId));

      return res.status(200).json({
        success: true,
        message: "Comment deleted successfully",
      });
    } catch (error) {
      console.error("Delete comment error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete comment",
      });
    }
  };
}

export default new CommentsController();
