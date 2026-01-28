## CompanyManagement (5 fonksiyon)

| #   | Fonksiyon             | Return Type                 | Aciklama                   |
|-----|-----------------------|-----------------------------|----------------------------|
| 1   | `core.company_list`   | JSONB `{items, totalCount}` | Sirket listesi (paginated) |
| 2   | `core.company_get`    | TABLE                       | Sirket bilgisi (by id)     |
| 3   | `core.company_create` | TABLE(id)           		| Yeni sirket olustur        |
| 4   | `core.company_update` | VOID                        | Sirket guncelle            |
| 5   | `core.company_delete` | VOID                        | Sirket sil (soft delete)   |
