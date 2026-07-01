using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyBooks.Service.Database
{
    [Table("WishKnjiga")]
    public partial class WishKnjiga
    {
        [Key]
        public int Id { get; set; }
        [StringLength(255)]
        public string Naslov { get; set; } = null!;
        [StringLength(255)]
        public string? Autor { get; set; }
        public string? Napomena { get; set; }
        [StringLength(50)]
        public string? Prioritet { get; set; }
        public byte[]? Slika { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime? DatumKreiranja { get; set; }
    }
}
