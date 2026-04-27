"""initial migration

Revision ID: 1234567890ab
Revises: 
Create Date: 2024-05-20 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '1234567890ab'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Add guest_id column to datasets table
    op.add_column('datasets', sa.Column('guest_id', sa.String(), nullable=True))
    # Add guest_id column to chat_history table
    op.add_column('chat_history', sa.Column('guest_id', sa.String(), nullable=True))

def downgrade() -> None:
    op.drop_column('chat_history', 'guest_id')
    op.drop_column('datasets', 'guest_id')
