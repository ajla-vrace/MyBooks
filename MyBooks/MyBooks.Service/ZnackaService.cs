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
    public class ZnackaService : BaseCRUDService<Model.Znacka, Database.Znacka, ZnackaSearchObject, ZnackaInsertRequest, ZnackaUpdateRequest>, IZnackaService
    {
        public ZnackaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Znacka> AddFilter(IQueryable<Database.Znacka> query, ZnackaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            // Ako je korisničko ime i naziv usluge uneseno

            return filteredQuery;
        }


        public override async Task<Model.Znacka> Insert(ZnackaInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.Znacka>(insert);

            // Postavi trenutni datum


            // Dodaj u bazu podataka
            _context.Znackas.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.Znacka>(entity);
        }


        public override async Task<Model.Znacka> Update(int id, ZnackaUpdateRequest update)
        {
            var entity = await _context.Znackas.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Znacka nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.Znackas.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Znacka>(entity);
        }
       /* public async Task ProvjeriZnacke(int korisnikId)
        {

            var brojKnjiga =
                await _context.Knjigas
                .CountAsync(x =>
                    x.KorisnikId == korisnikId);



            var brojCitata =
                await _context.Citats
                .CountAsync(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId);



            // 1. PRVA KNJIGA
            if (brojKnjiga >= 1)
            {
                await DodajZnackuAkoNema(
                    korisnikId,
                    1
                );
            }



            // 2. KNJIŠKI MOLJAC
            if (brojKnjiga >= 10)
            {
                await DodajZnackuAkoNema(
                    korisnikId,
                    2
                );
            }



            // 3. LJUBITELJ CITATA
            if (brojCitata >= 5)
            {
                await DodajZnackuAkoNema(
                    korisnikId,
                    3
                );
            }

        }




        private async Task DodajZnackuAkoNema(
            int korisnikId,
            int znackaId)
        {


            bool postoji =
                await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.ZnackaId == znackaId
                );



            if (!postoji)
            {

                var novaZnacka =
                    new Database.KorisnikZnacka
                    {

                        KorisnikId = korisnikId,

                        ZnackaId = znackaId,

                        DatumOtkljucavanja = DateTime.Now

                    };



                _context.KorisnikZnackas.Add(novaZnacka);



                await _context.SaveChangesAsync();

            }

        }*/
    }
}
