using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace MyBooks.Service.Database
{
    public partial class MyBooksContext : DbContext
    {
        public MyBooksContext()
        {
        }

        public MyBooksContext(DbContextOptions<MyBooksContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Citat> Citats { get; set; } = null!;
        public virtual DbSet<Knjiga> Knjigas { get; set; } = null!;
        public virtual DbSet<KnjigaZanr> KnjigaZanrs { get; set; } = null!;
        public virtual DbSet<Korisnik> Korisniks { get; set; } = null!;
        public virtual DbSet<KorisnikZnacka> KorisnikZnackas { get; set; } = null!;
        public virtual DbSet<WishKnjiga> WishKnjigas { get; set; } = null!;
        public virtual DbSet<Zanr> Zanrs { get; set; } = null!;
        public virtual DbSet<Znacka> Znackas { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Server=.;Database=MyBooks;Trusted_Connection=True;TrustServerCertificate=True;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Citat>(entity =>
            {
                entity.ToTable("Citat");

                entity.Property(e => e.DatumKreiranja)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.JeOmiljeni).HasDefaultValueSql("((0))");

                entity.HasOne(d => d.IdKnjigaNavigation)
                    .WithMany(p => p.Citats)
                    .HasForeignKey(d => d.IdKnjiga)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Citat__IdKnjiga__32E0915F");
            });

            modelBuilder.Entity<Knjiga>(entity =>
            {
                entity.ToTable("Knjiga");

                entity.Property(e => e.Autor).HasMaxLength(255);

                entity.Property(e => e.DatumKreiranja)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DatumPocetka).HasColumnType("date");

                entity.Property(e => e.DatumZavrsetka).HasColumnType("date");

                entity.Property(e => e.IsFavorite).HasDefaultValueSql("((0))");

                entity.Property(e => e.Mood).HasMaxLength(100);

                entity.Property(e => e.Naslov).HasMaxLength(255);

                entity.Property(e => e.Status).HasMaxLength(50);

                entity.HasOne(d => d.Korisnik)
                    .WithMany(p => p.Knjigas)
                    .HasForeignKey(d => d.KorisnikId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Knjiga__Korisnik__2E1BDC42");
            });

            modelBuilder.Entity<KnjigaZanr>(entity =>
            {
                entity.ToTable("KnjigaZanr");

                entity.HasOne(d => d.IdKnjigaNavigation)
                    .WithMany(p => p.KnjigaZanrs)
                    .HasForeignKey(d => d.IdKnjiga)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KnjigaZan__IdKnj__35BCFE0A");

                entity.HasOne(d => d.IdZanrNavigation)
                    .WithMany(p => p.KnjigaZanrs)
                    .HasForeignKey(d => d.IdZanr)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KnjigaZan__IdZan__36B12243");
            });

            modelBuilder.Entity<Korisnik>(entity =>
            {
                entity.ToTable("Korisnik");

                entity.HasIndex(e => e.Email, "UQ__Korisnik__A9D1053444DE9546")
                    .IsUnique();

                entity.Property(e => e.DatumRegistracije)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Email).HasMaxLength(150);

                entity.Property(e => e.GodisnjiCilj).HasDefaultValueSql("((20))");

                entity.Property(e => e.Ime).HasMaxLength(100);

                entity.HasOne(d => d.OmiljeniZanr)
                    .WithMany(p => p.Korisniks)
                    .HasForeignKey(d => d.OmiljeniZanrId)
                    .HasConstraintName("FK__Korisnik__Omilje__29572725");
            });

            modelBuilder.Entity<KorisnikZnacka>(entity =>
            {
                entity.ToTable("KorisnikZnacka");

                entity.Property(e => e.DatumOtkljucavanja)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.HasOne(d => d.Korisnik)
                    .WithMany(p => p.KorisnikZnackas)
                    .HasForeignKey(d => d.KorisnikId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KorisnikZ__Koris__403A8C7D");

                entity.HasOne(d => d.Znacka)
                    .WithMany(p => p.KorisnikZnackas)
                    .HasForeignKey(d => d.ZnackaId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KorisnikZ__Znack__412EB0B6");
            });

            modelBuilder.Entity<WishKnjiga>(entity =>
            {
                entity.ToTable("WishKnjiga");

                entity.Property(e => e.Autor).HasMaxLength(255);

                entity.Property(e => e.DatumKreiranja)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Naslov).HasMaxLength(255);

                entity.Property(e => e.Prioritet).HasMaxLength(50);

                entity.HasOne(d => d.Korisnik)
                    .WithMany(p => p.WishKnjigas)
                    .HasForeignKey(d => d.KorisnikId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__WishKnjig__Koris__3A81B327");
            });

            modelBuilder.Entity<Zanr>(entity =>
            {
                entity.ToTable("Zanr");

                entity.Property(e => e.Naziv).HasMaxLength(100);
            });

            modelBuilder.Entity<Znacka>(entity =>
            {
                entity.ToTable("Znacka");

                entity.Property(e => e.Ikonica).HasMaxLength(100);

                entity.Property(e => e.Naziv).HasMaxLength(100);

                entity.Property(e => e.Opis).HasMaxLength(500);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
