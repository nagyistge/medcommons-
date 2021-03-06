/**
 * @copyright
 * ====================================================================
 *    Licensed to the Apache Software Foundation (ASF) under one
 *    or more contributor license agreements.  See the NOTICE file
 *    distributed with this work for additional information
 *    regarding copyright ownership.  The ASF licenses this file
 *    to you under the Apache License, Version 2.0 (the
 *    "License"); you may not use this file except in compliance
 *    with the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing,
 *    software distributed under the License is distributed on an
 *    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *    KIND, either express or implied.  See the License for the
 *    specific language governing permissions and limitations
 *    under the License.
 * ====================================================================
 * @endcopyright
 *
 * @file dump_editor.h
 * @brief The svn_delta_editor_t editor used by svnrdump to dump
 * revisions.
 */

#ifndef DUMP_EDITOR_H_
#define DUMP_EDITOR_H_

/**
 * A directory baton used by all directory-related callback functions
 * in the dump editor.
 */
struct dir_baton
{
  struct dump_edit_baton *eb;
  struct dir_baton *parent_dir_baton;

  /* is this directory a new addition to this revision? */
  svn_boolean_t added;

  /* has this directory been written to the output stream? */
  svn_boolean_t written_out;

  /* the absolute path to this directory */
  const char *abspath;

  /* Copyfrom info for the node, if any */
  const char *copyfrom_path;
  svn_revnum_t copyfrom_rev;

  /* Hash of paths that need to be deleted, though some -might- be
     replaced.  Maps const char * paths to this dir_baton. Note that
     they're full paths, because that's what the editor driver gives
     us, although they're all really within this directory. */
  apr_hash_t *deleted_entries;
};

/**
 * A handler baton to be used in window_handler().
 */
struct handler_baton
{
  svn_txdelta_window_handler_t apply_handler;
  void *apply_baton;

  /* Pool used for temporary allocations during delta application in
     window_handler() */
  apr_pool_t *pool;

  /* Information about the path of the temporary file used */
  const char *delta_abspath;
  svn_stream_t *delta_filestream;

  /* Global edit baton */
  struct dump_edit_baton *eb;
};

/**
 * Get a dump editor @a editor along with a @a edit_baton allocated in
 * @a pool. The editor will write output to @a stream.
 */
svn_error_t *
get_dump_editor(const svn_delta_editor_t **editor,
                void **edit_baton,
                svn_stream_t *stream,
                apr_pool_t *pool);

#endif
