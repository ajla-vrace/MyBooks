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
    public class KorisnikZnackaService : BaseCRUDService<Model.KorisnikZnacka, Database.KorisnikZnacka, KorisnikZnackaSearchObject, KorisnikZnackaInsertRequest, KorisnikZnackaUpdateRequest>, IKorisnikZnackaService
    {
        public KorisnikZnackaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.KorisnikZnacka> AddFilter(
     IQueryable<Database.KorisnikZnacka> query,
     KorisnikZnackaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);


            if (search?.IdKorisnik.HasValue == true)
            {
                filteredQuery =
                    filteredQuery.Where(x =>
                    x.KorisnikId == search.IdKorisnik);
            }
            filteredQuery =
    filteredQuery
    .Include(x => x.Znacka);

            return filteredQuery;
        }


        public override async Task<Model.KorisnikZnacka> Insert(KorisnikZnackaInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.KorisnikZnacka>(insert);
            entity.DatumOtkljucavanja = DateTime.Now;

            var postoji = await _context.KorisnikZnackas
    .AnyAsync(x =>
        x.KorisnikId == insert.IdKorisnik &&
        x.ZnackaId == insert.IdZnacka);


            if (postoji)
            {
                return _mapper.Map<Model.KorisnikZnacka>(
                    await _context.KorisnikZnackas
                    .FirstAsync(x =>
                        x.KorisnikId == insert.IdKorisnik &&
                        x.ZnackaId == insert.IdZnacka)
                );
            }

            // Postavi trenutni datum
            // entity.DatumKreiranja = DateTime.Now;
            //entity.DatumPocetka = DateTime.Now;
            //entity.DatumZavrsetka = DateTime.Now;

            // Dodaj u bazu podataka
            _context.KorisnikZnackas.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }


        public override async Task<Model.KorisnikZnacka> Update(int id, KorisnikZnackaUpdateRequest update)
        {
            var entity = await _context.KorisnikZnackas.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("KorisnikZnacka nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.KorisnikZnackas.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }
        public async Task ProvjeriZnacke(int korisnikId)
        {
            var brojKnjiga =
                await _context.Knjigas
                .CountAsync(x => x.KorisnikId == korisnikId);


            var brojCitata =
                await _context.Citats
                .CountAsync(x => x.IdKnjigaNavigation.KorisnikId == korisnikId);



            if (brojKnjiga >= 1)
            {
                await DodajZnackuAkoNema(korisnikId, 1);
            }

            if (brojKnjiga >= 5)
            {
                await DodajZnackuAkoNema(korisnikId, 2);
            }

            if (brojKnjiga >= 10)
            {
                await DodajZnackuAkoNema(korisnikId, 3);
            }
        }



        private async Task DodajZnackuAkoNema(
            int korisnikId,
            int znackaId)
        {
            var postoji =
                await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.ZnackaId == znackaId);


            if (!postoji)
            {
                _context.KorisnikZnackas.Add(
                    new Database.KorisnikZnacka
                    {
                        KorisnikId = korisnikId,
                        ZnackaId = znackaId,
                        DatumOtkljucavanja = DateTime.Now
                    }
                );

                await _context.SaveChangesAsync();
            }
        }
    }
}
