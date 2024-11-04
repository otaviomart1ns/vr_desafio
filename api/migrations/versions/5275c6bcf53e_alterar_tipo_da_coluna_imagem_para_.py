"""Alterar tipo da coluna imagem para MEDIUMBLOB

Revision ID: 5275c6bcf53e
Revises: 5a8c37ab29fb
Create Date: 2024-10-29 05:30:09.878556

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '5275c6bcf53e'
down_revision = '5a8c37ab29fb'
branch_labels = None
depends_on = None


def upgrade():
    op.alter_column('produto', 'imagem',
                    existing_type=sa.LargeBinary(),
                    type_=sa.LargeBinary(length=(2**24)-1),
                    nullable=True)


def downgrade():
    op.alter_column('produto', 'imagem',
                    existing_type=sa.LargeBinary(),
                    type_=sa.LargeBinary(),
                    nullable=True)
