import go

from IfStmt i
where
i.getCond().(EqualityTestExpr).getAnOperand().(Ident).getName() = "ErrNone"
and not i.getThen().getAStmt() instanceof ReturnStmt
select i

