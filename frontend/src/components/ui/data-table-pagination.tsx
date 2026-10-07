import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
} from "./pagination";

interface DataTablePaginationProps {
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export function DataTablePagination({ page, totalPages, onPageChange }: DataTablePaginationProps) {
  if (totalPages <= 0) return null;

  const pages = [];
  for (let i = 1; i <= totalPages; i++) {
    if (i === 1 || i === totalPages || Math.abs(i - page) <= 1) {
      pages.push(i);
    } else if (pages[pages.length - 1] !== '...') {
      pages.push('...');
    }
  }

  return (
    <div className="flex items-center justify-end px-2 mt-4 pb-4">
      <Pagination>
        <PaginationContent>
          <PaginationItem>
            <PaginationPrevious 
              onClick={(e) => {
                e.preventDefault();
                onPageChange(Math.max(1, page - 1));
              }}
              className={page === 1 ? "pointer-events-none opacity-50" : "cursor-pointer"}
              href="#"
            />
          </PaginationItem>
          
          {pages.map((p, i) => (
            <PaginationItem key={i}>
              {p === '...' ? (
                <PaginationEllipsis />
              ) : (
                <PaginationLink
                  onClick={(e) => {
                    e.preventDefault();
                    onPageChange(p as number);
                  }}
                  isActive={page === p}
                  className="cursor-pointer"
                  href="#"
                >
                  {p}
                </PaginationLink>
              )}
            </PaginationItem>
          ))}

          <PaginationItem>
            <PaginationNext 
              onClick={(e) => {
                e.preventDefault();
                onPageChange(Math.min(totalPages, page + 1));
              }}
              className={page === totalPages ? "pointer-events-none opacity-50" : "cursor-pointer"}
              href="#"
            />
          </PaginationItem>
        </PaginationContent>
      </Pagination>
    </div>
  );
}
