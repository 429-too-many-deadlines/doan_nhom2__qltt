"use client"

import * as React from "react"
import { Check, ChevronsUpDown } from "lucide-react"

import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { useDebounce } from "@/hooks/use-debounce"

export interface Option {
  value: string
  label: string
}

interface AsyncComboboxProps {
  value: string
  onChange: (value: string) => void
  fetcher: (query: string) => Promise<Option[]>
  defaultOptions?: Option[]
  placeholder?: string
  emptyText?: string
  className?: string
  disabled?: boolean
}

export function AsyncCombobox({
  value,
  onChange,
  fetcher,
  defaultOptions = [],
  placeholder = "Select an item...",
  emptyText = "No items found.",
  className,
  disabled = false,
}: AsyncComboboxProps) {
  const [open, setOpen] = React.useState(false)
  const [options, setOptions] = React.useState<Option[]>(defaultOptions)
  const [loading, setLoading] = React.useState(false)
  const [search, setSearch] = React.useState("")
  const debouncedSearch = useDebounce(search, 500)

  // Nếu người dùng có selected value, ta cần đảm bảo có option hiển thị
  // nếu nó không nằm trong defaultOptions
  const [selectedLabel, setSelectedLabel] = React.useState<string>("")

  React.useEffect(() => {
    // Cập nhật selected label từ options nếu có
    const selected = options.find((opt) => opt.value === value)
    if (selected) {
      setSelectedLabel(selected.label)
    } else if (defaultOptions.find(opt => opt.value === value)) {
      setSelectedLabel(defaultOptions.find(opt => opt.value === value)!.label)
    }
  }, [value, options, defaultOptions])

  React.useEffect(() => {
    let isMounted = true

    const loadData = async () => {
      setLoading(true)
      try {
        const results = await fetcher(debouncedSearch)
        if (isMounted) {
          setOptions(results)
        }
      } catch (error) {
        console.error("Failed to fetch options", error)
      } finally {
        if (isMounted) {
          setLoading(false)
        }
      }
    }

    if (open) {
      loadData()
    }

    return () => {
      isMounted = false
    }
  }, [debouncedSearch, open, fetcher])

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className={cn("w-full justify-between font-normal", className)}
          disabled={disabled}
        >
          {selectedLabel || value || placeholder}
          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-full p-0" align="start">
        <Command shouldFilter={false}>
          <CommandInput
            placeholder="Search..."
            value={search}
            onValueChange={setSearch}
          />
          <CommandList>
            <CommandEmpty>{loading ? "Loading..." : emptyText}</CommandEmpty>
            <CommandGroup>
              {options.map((option) => (
                <CommandItem
                  key={option.value}
                  value={option.value}
                  onSelect={(currentValue) => {
                    // command component in shadcn converts value to lowercase internally.
                    // To be safe, we just use the option.value
                    onChange(option.value === value ? "" : option.value)
                    setOpen(false)
                    setSearch("")
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      value === option.value ? "opacity-100" : "opacity-0"
                    )}
                  />
                  {option.label}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  )
}
