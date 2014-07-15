/*
 * Copyright (c) 2014 flightonary <flightonary@users.noreply.github.com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of mosquitto nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <string.h>
#include <stdlib.h>
#include <mosquitto.h>
#include "topic.h"

char *strrep(const char *input, const char *search, const char *replace) {
    size_t searchLen, replaceLen, delta;
    char *find, *buf, *reallocTmp;

    if(!input)
        return NULL;

    searchLen = strlen(search);
    replaceLen = strlen(replace);
    delta = replaceLen - searchLen;
    buf = strdup(input);
    find = buf;
    while ((find = strstr(find, search))) {
        if (delta > 0) {
            reallocTmp = realloc(buf, strlen(buf) + delta + 1);
            if (!reallocTmp){
                free(buf);
                return NULL;
            }
            buf = reallocTmp;
            find = strstr(buf, search);
        }
        memmove(find + replaceLen, find + searchLen, strlen(buf) - ((find - buf) + searchLen) + 1);
        memcpy(find, replace, replaceLen);
    }
    return buf;
}

/*
 * Function: topic_replace_substitution
 *
 * Replace substitution of clientid and username in topic
 *
 * %c would be replaced to clientid
 * %u would be replaced to username
 *
 * Parameters:
 *  topic - subscription string to be replaced
 *  clientid - clientid string
 *  username - username string
 *
 * Returns:
 *  Return replaced string address
 *  This function allocates the memory for the new string by calling malloc();
 *  it's up to you to release the memory by calling free().
 */
char *topic_replace_substitution(const char *topic, const char *clientid, const char *username) {
    char *replaced_c = NULL, *replaced_u = NULL;

    replaced_c = strrep(topic, "%c", clientid);
    replaced_u = strrep(replaced_c, "%u", username);
    free(replaced_c);

    return replaced_u;
}

/*
 * Function: topic_matches_sub_with_substitution
 *
 * Check whether a topic matches a subscription with substitution.

 * %c would be replaced to clientid
 * %u would be replaced to username
 *
 * For example:
 *
 * foo/bar would match the subscription foo/# or +/bar
 * non/matching would not match the subscription non/+/+
 *
 * Parameters:
 *  sub - subscription string to check topic against.
 *  topic - topic to check.
 *  clientid - clientid string
 *  username - username string
 *  result - bool pointer to hold result. Will be set to true if the topic
 *           matches the subscription.
 *
 * Returns:
 *  MOSQ_ERR_SUCCESS - on success
 *  MOSQ_ERR_INVAL -   if the input parameters were invalid.
 *  MOSQ_ERR_NOMEM -   if an out of memory condition occurred.
 */
int topic_matches_sub_with_substitution(const char *sub, const char *topic, const char *clientid, const char *username, bool *result) {
    char *topic_r = NULL;
    int ret = MOSQ_ERR_NOMEM;

    topic_r = topic_replace_substitution(sub, clientid, username);
    if (!topic_r)
        return ret;

    ret = mosquitto_topic_matches_sub(topic_r, topic, result);
    free(topic_r);
    return ret;
}
