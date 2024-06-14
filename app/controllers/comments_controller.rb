class CommentsController < ApplicationController
  before_action :authenticate_user, only: %i[create destroy]

  def index
    article = Article.find_by_slug(params[:article_id])
    comments = article.comments
    render json: { comments: comments.map(&:to_hash) }
  end

  def create
    article = Article.find_by_slug(params[:article_id])
    comment = Comment.new(comment_params)
    comment.author_id = current_user.id
    article.add_comment(comment)
    if comment.save
      render json: { comment: comment.to_hash }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    article = Article.find_by_slug(params[:article_id])
    comment = article.comments.find(params[:id]) if article

    if comment && comment.author_id == current_user.id
      comment.destroy
      render json: { message: 'Comment deleted successfully' }, status: :no_content
    else
      render json: { errors: ['You are not authorized to delete this comment'] }, status: :forbidden
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :article_id, :id)
  end
end
