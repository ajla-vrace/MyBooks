using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyBooks.Model;
using MyBooks.Service;

namespace MyBooks.Service
{
    public class KnjigaService : BaseCRUDService<Model.Knjiga, Database.Knjiga, KnjigaSearchObject, KnjigaInsertRequest, KnjigaUpdateRequest>, IKnjigaService
    {
        public KnjigaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }
       
        public override IQueryable<Database.Knjiga> AddFilter(IQueryable<Database.Knjiga> query, KnjigaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naslov))
            {
                filteredQuery = filteredQuery.Where(x => x.Naslov.Contains(search.Naslov));
            }
            if (!string.IsNullOrWhiteSpace(search?.Autor))
            {
                filteredQuery = filteredQuery.Where(x => x.Autor.Contains(search.Autor));
            }
            filteredQuery = filteredQuery
   .Include(x => x.KnjigaZanrs)
       .ThenInclude(x => x.IdZanrNavigation);
            if (search?.ZanrId != null)
            {
                int zanrId = search.ZanrId.Value;

                filteredQuery = filteredQuery.Where(x =>
                    x.KnjigaZanrs.Any(kz => kz.IdZanr == zanrId)
                );
            }


            // Ako je korisničko ime i naziv usluge uneseno
          

            return filteredQuery;
        }


        /* public override async Task<Model.Knjiga> Insert(KnjigaInsertRequest insert)
         {
             // Kreiraj novi entitet na osnovu request-a
             var entity = _mapper.Map<Database.Knjiga>(insert);

             // Postavi trenutni datum
             entity.DatumKreiranja = DateTime.Now;
             entity.DatumPocetka = DateTime.Now;
             entity.DatumZavrsetka = DateTime.Now;

             // Dodaj u bazu podataka
             _context.Knjigas.Add(entity);
             await _context.SaveChangesAsync();

             // Vrati mapirani model
             return _mapper.Map<Model.Knjiga>(entity);
         }*/
        /* public override async Task<Model.Knjiga> Insert(KnjigaInsertRequest insert)
         {
             var entity = _mapper.Map<Database.Knjiga>(insert);

             entity.DatumKreiranja = DateTime.Now;
             entity.DatumPocetka = DateTime.Now;
             entity.DatumZavrsetka = DateTime.Now;

             _context.Knjigas.Add(entity);
             await _context.SaveChangesAsync();

             // 🔥 DODANO: VEZIVANJE ŽANROVA
             if (insert.ZanroviIds != null && insert.ZanroviIds.Count > 0)
             {
                 foreach (var zanrId in insert.ZanroviIds)
                 {
                     _context.KnjigaZanrs.Add(new Database.KnjigaZanr
                     {
                         IdKnjiga = entity.Id,
                         IdZanr = zanrId
                     });
                 }

                 await _context.SaveChangesAsync();
             }

             return _mapper.Map<Model.Knjiga>(entity);
         }*/
       
        public override async Task<Model.Knjiga> Insert(KnjigaInsertRequest insert)
        {
            var entity = _mapper.Map<Database.Knjiga>(insert);

            if (!string.IsNullOrEmpty(insert.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(insert.SlikaBase64);
            }

            entity.DatumKreiranja = DateTime.Now;
            entity.DatumPocetka = DateTime.Now;
            entity.DatumZavrsetka = DateTime.Now;

            _context.Knjigas.Add(entity);
            await _context.SaveChangesAsync();

            if (insert.ZanroviIds != null && insert.ZanroviIds.Count > 0)
            {
                foreach (var zanrId in insert.ZanroviIds)
                {
                    _context.KnjigaZanrs.Add(new Database.KnjigaZanr
                    {
                        IdKnjiga = entity.Id,
                        IdZanr = zanrId
                    });
                }

                await _context.SaveChangesAsync();
            }

            var knjiga = await _context.Knjigas
                .Include(k => k.KnjigaZanrs)
                .ThenInclude(kz => kz.IdZanrNavigation)
                .FirstAsync(k => k.Id == entity.Id);

            return _mapper.Map<Model.Knjiga>(knjiga);
        }


        public override async Task<Model.Knjiga> Update(int id, KnjigaUpdateRequest update)
        {
            var entity = await _context.Knjigas.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Knjiga nije pronađen.");
            }

            _mapper.Map(update, entity);
           

            _context.Knjigas.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Knjiga>(entity);
        }
        public async Task<StatistikaResponse> GetStatistika()
        {
            var knjige = await _context.Knjigas
                .Include(x => x.KnjigaZanrs)
                .ThenInclude(x => x.IdZanrNavigation)
                .ToListAsync();

            var result = new StatistikaResponse();

            result.UkupnoKnjiga = knjige.Count;

            result.ProsjecnaOcjena = knjige.Any()
                ? knjige.Average(x => x.Ocjena ?? 0)
                : 0;

            result.KnjigePoMjesecima = knjige
                .GroupBy(x => x.DatumKreiranja!.Value.Month)
                .Select(x => new BrojPoMjesecu
                {
                    Mjesec = x.Key.ToString(),
                    Broj = x.Count()
                })
                .OrderBy(x => int.Parse(x.Mjesec))
                .ToList();

            var sviZanrovi = knjige
                .SelectMany(x => x.KnjigaZanrs)
                .GroupBy(x => x.IdZanrNavigation.Naziv)
                .Select(x => new ZanrStatistika
                {
                    Naziv = x.Key,
                    Broj = x.Count(),
                    Postotak = 0
                })
                .OrderByDescending(x => x.Broj)
                .Take(3)
                .ToList();

            int ukupnoZanrova = sviZanrovi.Sum(x => x.Broj);

            foreach (var z in sviZanrovi)
            {
                z.Postotak = ukupnoZanrova == 0
                    ? 0
                    : Math.Round((double)z.Broj / ukupnoZanrova * 100, 1);
            }

            result.TopZanrovi = sviZanrovi;

            return result;
        }
        public override async Task<bool> Delete(int id)
        {
            var entity = await _context.Knjigas
                .Include(x => x.KnjigaZanrs)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return false;

            _context.KnjigaZanrs.RemoveRange(entity.KnjigaZanrs);
            _context.Knjigas.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
